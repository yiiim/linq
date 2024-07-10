import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'annotation/linq.dart';
import 'entity.dart';
import 'linq_model.dart';
import 'pseudo.dart';
import 'query_descriptor.dart';
import 'set.dart';

class _QueryModelFieldDescriptor<TModelType, TDataType, TValueType> extends QueryModelFieldDescriptor<TDataType, TValueType> {
  _QueryModelFieldDescriptor({
    required this.original,
  }) : super(
          defaultValue: original.defaultValue,
          name: original.name,
          dbName: original.dbName,
          isPrimaryKey: original.isPrimaryKey,
          codec: original.codec,
        );

  final QueryModelFieldDescriptor<TModelType, TValueType> original;

  @override
  dynamic getDbValue(TDataType model) {
    return codec?.encoder.convert(get!(model)) ?? get!(model);
  }

  @override
  void setDbValue(TDataType model, dynamic value) {
    set!(model, codec?.decoder.convert(value) ?? value);
  }
}

class _LinqObject<T extends LinqModel> extends LinqObject<T> {
  _LinqObject._({
    required T object,
    required LinqEntity<T> entity,
    required LinqContext context,
    List<QueryModelFieldDescriptor> hasValueFields = const [],
  })  : _context = context,
        _entity = entity,
        _object = object,
        _hasValueFields = hasValueFields;

  final LinqEntity<T> _entity;
  final LinqContext _context;
  final T _object;
  final List<QueryModelFieldDescriptor> _hasValueFields;
  final List<ModelListener<T>> _listeners = [];

  @override
  void update(void Function(LinqPseudoClass<T, T>) block) {
    var pClass = _LinqPseudoClass<T, T>(context: _context, model: _LinqTemporaryModel(_object), entity: _entity);
    final updateFields = pClass.updateFields(
      (pClass) {
        block(pClass);
        for (var element in _listeners) {
          element.didUpdate(pClass, _object);
        }
        _context.didUpdateModel(pClass, _object);
      },
    );
    _context._updateEntity<T>(_entity, updateFields, _object);
  }

  @override
  void remove() {
    _context._deleteEntity(_entity, _object);
    for (var listener in _listeners) {
      listener.didRmove(_object);
    }
  }

  @override
  void addListener(ModelListener<T> listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(ModelListener<T> listener) {
    _listeners.remove(listener);
  }
}

class _LinqTemporaryModel<T> {
  _LinqTemporaryModel(this.model);
  final T model;
  Map<_LinqContextSet, _LinqTemporaryModel> temporaryModels = {};

  _LinqTemporaryModel<E>? findChild<E>({Object? key}) {
    final child = temporaryModels.entries.firstWhereOrNull((element) => element.key.key == key && element.value is _LinqTemporaryModel<E>)?.value;
    if (child != null) {
      return child as _LinqTemporaryModel<E>;
    }
    for (var element in temporaryModels.entries) {
      final result = element.value.findChild<E>(key: key);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

String nextPrefix(String? prefix) {
  if (prefix == null || prefix.isEmpty) {
    return 'a';
  }

  List<String> chars = prefix.split('');
  for (int i = chars.length - 1; i >= 0; i--) {
    if (chars[i] != 'z') {
      chars[i] = String.fromCharCode(chars[i].codeUnitAt(0) + 1);
      break;
    } else {
      chars[i] = 'a';
      if (i == 0) {
        chars.insert(0, 'a');
      }
    }
  }

  return chars.join('');
}

abstract class _LinqWhereValue {
  List get args;
  String toSql({required String alias, LinqWhereLikeOperator? like});
}

class _LinqWhereConstantValue<T> extends _LinqWhereValue {
  _LinqWhereConstantValue(this.value, {this.codec});
  final T? value;
  final DataFieldCodec? codec;

  @override
  String toSql({required String alias, LinqWhereLikeOperator? like}) {
    if (like != null) {
      switch (like) {
        case LinqWhereLikeOperator.start:
          return "?%";
        case LinqWhereLikeOperator.end:
          return "%?";
        case LinqWhereLikeOperator.both:
          return "%?%";
      }
    }
    return "?";
  }

  @override
  List get args => [value == null ? null : codec?.encode(value) ?? value];
}

class _LinqWhereConstantInValue<T> extends _LinqWhereValue {
  _LinqWhereConstantInValue(this.value, {this.codec});
  final List<T> value;
  final DataFieldCodec? codec;
  @override
  String toSql({required String alias, LinqWhereLikeOperator? like}) {
    assert(like == null);
    return "(${value.map((e) => "?").join(", ")})";
  }

  @override
  List get args => value.map((e) => e == null ? null : codec?.encode(e) ?? e).toList();
}

class _LinqQueryWhereField<T, E> extends LinqWherePropertyField<T, E> implements _LinqWhereValue {
  _LinqQueryWhereField({
    this.prefix,
    required this.field,
  });
  final String? prefix;
  final QueryModelFieldDescriptor<T, E> field;

  @override
  LinqWhere equal<G>(LinqWherePropertyField<G, E> other) => _LinqQueryWhereOperator(
        left: this,
        right: other as _LinqQueryWhereField<G, E>,
        operator: LinqWhereOperator.equal,
      );
  @override
  LinqWhere notEqual<G>(LinqWherePropertyField<G, E> other) => _LinqQueryWhereOperator(
        left: this,
        right: other as _LinqQueryWhereField<G, E>,
        operator: LinqWhereOperator.notEqual,
      );
  @override
  LinqWhere equalValue(E? value) => _LinqQueryWhereOperator(
        left: this,
        right: value == null ? null : _LinqWhereConstantValue(value, codec: field.codec),
        operator: value == null ? LinqWhereOperator.isNull : LinqWhereOperator.equal,
      );
  @override
  LinqWhere likeValue(E value, {LinqWhereLikeOperator likeOperator = LinqWhereLikeOperator.both}) => _LinqQueryWhereOperator(
        left: this,
        right: value == null ? null : _LinqWhereConstantValue(value, codec: field.codec),
        operator: value == null ? LinqWhereOperator.isNull : LinqWhereOperator.like,
        likeOperator: likeOperator,
      );

  @override
  LinqWhere notEqualValue(E? value) => _LinqQueryWhereOperator(
        left: this,
        right: value == null ? null : _LinqWhereConstantValue(value, codec: field.codec),
        operator: value == null ? LinqWhereOperator.isNotNull : LinqWhereOperator.notEqual,
      );

  @override
  LinqWhere inValues(List<E> values) => _LinqQueryWhereOperator(
        left: this,
        right: _LinqWhereConstantInValue(values, codec: field.codec),
        operator: LinqWhereOperator.inList,
      );

  @override
  LinqWhere notInValues(List<E> values) => _LinqQueryWhereOperator(
        left: this,
        right: _LinqWhereConstantInValue(values, codec: field.codec),
        operator: LinqWhereOperator.notInList,
      );
  @override
  LinqWhere lessThanValue(E value) => _LinqQueryWhereOperator(
        left: this,
        right: value == null ? null : _LinqWhereConstantValue(value, codec: field.codec),
        operator: LinqWhereOperator.lessThan,
      );
  @override
  LinqWhere lessThanOrEqualValue(E value) => _LinqQueryWhereOperator(
        left: this,
        right: value == null ? null : _LinqWhereConstantValue(value, codec: field.codec),
        operator: LinqWhereOperator.lessThanOrEqual,
      );
  @override
  LinqWhere greaterThanValue(E value) => _LinqQueryWhereOperator(
        left: this,
        right: value == null ? null : _LinqWhereConstantValue(value, codec: field.codec),
        operator: LinqWhereOperator.greaterThan,
      );
  @override
  LinqWhere greaterThanOrEqualValue(E value) => _LinqQueryWhereOperator(
        left: this,
        right: value == null ? null : _LinqWhereConstantValue(value, codec: field.codec),
        operator: LinqWhereOperator.greaterThanOrEqual,
      );

  @override
  String toSql({required String alias, LinqWhereLikeOperator? like}) {
    var valueSql = "`$alias`.`${field.dbName}`";
    if (prefix?.isNotEmpty == true) {
      valueSql = "`$alias`.`${prefix}_${field.dbName}`";
    }
    if (like != null) {
      switch (like) {
        case LinqWhereLikeOperator.start:
          return "%$valueSql";
        case LinqWhereLikeOperator.end:
          return "$valueSql%";
        case LinqWhereLikeOperator.both:
          return "%$valueSql%";
      }
    }
    return valueSql;
  }

  @override
  List get args => [];
}

class _LinqQueryWhereOperator extends LinqWhere {
  _LinqQueryWhereOperator({
    required this.left,
    this.right,
    this.likeOperator,
    required this.operator,
  });
  _LinqWhereValue left;
  LinqWhereOperator operator;
  LinqWhereLikeOperator? likeOperator;
  _LinqWhereValue? right;

  @override
  String toSql({required String alias}) {
    final String operatorSql = switch (operator) {
      LinqWhereOperator.equal => "=",
      LinqWhereOperator.notEqual => "!=",
      LinqWhereOperator.greaterThan => ">",
      LinqWhereOperator.greaterThanOrEqual => ">=",
      LinqWhereOperator.lessThan => "<",
      LinqWhereOperator.lessThanOrEqual => "<=",
      LinqWhereOperator.like => "LIKE",
      LinqWhereOperator.notLike => "NOT LIKE",
      LinqWhereOperator.inList => "IN",
      LinqWhereOperator.notInList => "NOT IN",
      LinqWhereOperator.isNull => "IS NULL",
      LinqWhereOperator.isNotNull => "IS NOT NULL",
    };
    return "${left.toSql(alias: alias)} $operatorSql${right == null ? "" : " ${right!.toSql(alias: alias)}"}";
  }

  @override
  LinqWhere and(LinqWhere other) {
    return _LinqQueryWhereMultiple()
      ..append(this)
      ..append(other, operator: LinqWhereJoinOperator.and);
  }

  @override
  LinqWhere or(LinqWhere other) {
    return _LinqQueryWhereMultiple()
      ..append(this)
      ..append(other, operator: LinqWhereJoinOperator.or);
  }

  @override
  LinqWhere group() {
    return _LinqQueryWhereGroup(original: this);
  }

  @override
  List get args => [
        ...left.args,
        ...right?.args.map(
              (e) {
                if (likeOperator != null && e is String) {
                  switch (likeOperator!) {
                    case LinqWhereLikeOperator.start:
                      return "$e%";
                    case LinqWhereLikeOperator.end:
                      return "%$e";
                    case LinqWhereLikeOperator.both:
                      return "%$e%";
                  }
                }
                return e;
              },
            ) ??
            []
      ];
}

class _LinqQueryWhereMultiple extends LinqWhere {
  _LinqQueryWhereMultiple();
  final List _items = [];
  void append(LinqWhere where, {LinqWhereJoinOperator? operator}) {
    if (operator != null) {
      _items.add(operator);
    }
    _items.add(where);
  }

  @override
  LinqWhere and(LinqWhere other) {
    append(other, operator: LinqWhereJoinOperator.and);
    return this;
  }

  @override
  String toSql({required String alias}) {
    assert(
      () {
        if (_items.isEmpty) {
          return false;
        }
        if (_items.first is! LinqWhere) {
          return false;
        }
        if (_items.last is! LinqWhere) {
          return false;
        }
        for (int i = 1; i < _items.length; i += 2) {
          if (_items[i] is! LinqWhereJoinOperator) {
            return false;
          }
          if (_items[i + 1] is! LinqWhere) {
            return false;
          }
        }
        return true;
      }(),
    );
    StringBuffer sb = StringBuffer();
    for (var element in _items) {
      sb.write(
        switch (element) {
          LinqWhere() => element.toSql(alias: alias),
          LinqWhereJoinOperator.and => " AND ",
          LinqWhereJoinOperator.or => " OR ",
          _ => "",
        },
      );
    }
    return sb.toString();
  }

  @override
  LinqWhere group() {
    return _LinqQueryWhereGroup(original: this);
  }

  @override
  LinqWhere or(LinqWhere other) {
    append(other, operator: LinqWhereJoinOperator.or);
    return this;
  }

  @override
  List get args => _items.whereType<LinqWhere>().expand((element) => element.args).toList();
}

class _LinqQueryWhereGroup extends LinqWhere {
  _LinqQueryWhereGroup({
    required this.original,
  });
  final LinqWhere original;
  @override
  LinqWhere and(LinqWhere other) {
    return _LinqQueryWhereMultiple()
      ..append(this)
      ..append(other, operator: LinqWhereJoinOperator.and);
  }

  @override
  LinqWhere or(LinqWhere other) {
    return _LinqQueryWhereMultiple()
      ..append(this)
      ..append(other, operator: LinqWhereJoinOperator.or);
  }

  @override
  String toSql({required String alias}) {
    return "(${original.toSql(alias: alias)})";
  }

  @override
  LinqWhere group() {
    return this;
  }

  @override
  List get args => original.args;
}

class _LinqWherePseudoClass<T, TDataType> extends LinqWherePseudoClass<T, TDataType> {
  _LinqWherePseudoClass({required this.context, required this.pseudoClass});
  final LinqContext context;
  final _LinqPseudoClass<T, TDataType> pseudoClass;
  @override
  LinqWherePropertyField<TDataType, F> whereField<F>(String name) {
    return _LinqQueryWhereField<TDataType, F>(
      // prefix: pseudoClass.prefix,
      field: pseudoClass._dataFieldByName<F>(name),
    );
  }

  @override
  LinqWherePseudoClass<F, TDataType> reverse<F>({Object? key}) {
    return _LinqWherePseudoClass<F, TDataType>(
      context: context,
      pseudoClass: pseudoClass.reverse<F>(key: key),
    );
  }
}

class _JoinOnSelectResult<T, E, F> extends JoinOnSelectResult<T, E, F> {
  _JoinOnSelectResult({required this.left, required this.right, required this.type});
  final QueryJoinType type;
  final QueryModelFieldDescriptor<T, F> left;
  final QueryModelFieldDescriptor<E, F> right;
  @override
  JoinOnResult<T, E, F, G> select<G>(G Function(LinqPseudoClass<T, T> p0, LinqPseudoClass<E, E> p1) select) {
    return JoinOnResult<T, E, F, G>(
      left,
      right,
      select,
      type: type,
    );
  }
}

class _LinqContextJoinOnItem<T, F> extends JoinOnItem<T, F> {
  _LinqContextJoinOnItem({
    required this.context,
    required this.field,
  });

  final LinqContext context;
  @override
  JoinOnSelectResult<T, E, F> on<E>(JoinOnItem<E, F> other, {QueryJoinType type = QueryJoinType.inner}) {
    return _JoinOnSelectResult<T, E, F>(
      left: field,
      right: (other as _LinqContextJoinOnItem<E, F>).field,
      type: type,
    );
  }

  final QueryModelFieldDescriptor<T, F> field;
}

class _LinqJoinOnPseudoClass<TModelType, TDataType> extends LinqJoinOnPseudoClass<TModelType, TDataType> {
  _LinqJoinOnPseudoClass(this.context, this.pseudoClass);

  final LinqContext context;
  final _LinqPseudoClass<TModelType, TDataType> pseudoClass;

  @override
  JoinOnItem<TDataType, TValueType> joinField<TValueType>(String name) {
    return _LinqContextJoinOnItem<TDataType, TValueType>(
      context: context,
      field: pseudoClass._dataFieldByName<TValueType>(name),
    );
  }

  @override
  LinqJoinOnPseudoClass<F, TDataType> reverse<F>({Object? key}) {
    return _LinqJoinOnPseudoClass<F, TDataType>(
      context,
      pseudoClass.reverse<F>(),
    );
  }
}

abstract class _ReversePseudoClassDelegate {
  _LinqPseudoClass<T, E>? createReverse<T, E>({String prefix = "", Object? key, _LinqTemporaryModel? model});
}

class _LinqPseudoClass<TModelType, TDataType> extends LinqPseudoClass<TModelType, TDataType> {
  _LinqPseudoClass({
    this.model,
    required this.context,
    this.entity,
    this.reverseDelegate,
    this.prefix = "",
  });

  _ReversePseudoClassDelegate? reverseDelegate;
  final LinqContext context;
  final String prefix;
  final LinqEntity? entity;
  final _LinqTemporaryModel<TModelType>? model;
  _LinqPseudoClass? forward;
  Set _fileds = {};

  void _get<TValueType>(QueryModelFieldDescriptor field) {
    forward?._get(field);
    _fileds.add(field);
  }

  void _set<TValueType>(QueryModelFieldDescriptor field, TValueType newValue) {
    forward?._set(
      field,
      newValue,
    );
    _fileds.add(
      LinqPseudoClassUpdateField(field, newValue),
    );
  }

  @override
  TValueType get<TValueType>(String name) {
    final field = _leftFieldByName<TValueType>(name);
    _get(field);
    if (entity != null && model != null && model?.model is LinqModel) {
      _LinqObject object = (model?.model as LinqModel).linqObject as _LinqObject;
      if (object._hasValueFields.any((element) => element.name == field.name)) {
        return field.get!(model?.model as TModelType);
      }
    }
    if (null is TValueType) return null as TValueType;
    return field.defaultValue;
  }

  @override
  void set<F>(String name, F newValue) {
    final field = _leftFieldByName<F>(name);
    _set(field, newValue);
    field.set?.call(model?.model as TModelType, newValue);
  }

  QueryModelFieldDescriptor<TModelType, F> _leftFieldByName<F>(String name) {
    var field = entity!.fields().firstWhere((element) => element.name == name);
    field = field.copyWith(dbName: [if (prefix.isNotEmpty) prefix, field.dbName].join("_"));
    return field as QueryModelFieldDescriptor<TModelType, F>;
  }

  QueryModelFieldDescriptor<TDataType, F> _dataFieldByName<F>(String name) {
    final field = _leftFieldByName<F>(name);
    return _QueryModelFieldDescriptor<TModelType, TDataType, F>(
      original: field,
    );
  }

  List<QueryModelFieldDescriptor> selectFields(void Function(_LinqPseudoClass<TModelType, TDataType>) block) {
    _fileds = {};
    block(this);
    return _fileds.whereType<QueryModelFieldDescriptor>().toList();
  }

  List<LinqPseudoClassUpdateField> updateFields(void Function(_LinqPseudoClass<TModelType, TDataType>) block) {
    _fileds = {};
    block(this);
    return _fileds.whereType<LinqPseudoClassUpdateField>().toList();
  }

  @override
  _LinqPseudoClass<TReverseModelType, TDataType> reverse<TReverseModelType>({Object? key}) {
    final result = reverseDelegate?.createReverse<TReverseModelType, TDataType>(prefix: prefix, key: key, model: model);
    if (result == null) {
      throw Exception("Can't reverse to $TReverseModelType");
    }
    result.forward = this;
    return result;
  }

  @override
  TModelType selectAll() {
    if (entity == null) {
      throw Exception("selectAll only support entity");
    }
    for (var element in entity!.fields()) {
      _get(element);
    }
    return model?.model ?? entity!.create() as TModelType;
  }
}

abstract class _LinqContextSet<T extends Object> extends LinqSet<T> implements QueryDescriptor<T>, _ReversePseudoClassDelegate {
  _LinqContextSet({
    required this.context,
  }) {
    alias = context._nextPrefix();
  }
  int? _take;
  int? _skip;
  bool _descending = false;
  QueryModelFieldDescriptor? _orderBy;
  LinqWhere? _where;
  List _args = [];

  late final String alias;
  final LinqContext context;
  List<QueryModelFieldDescriptor> get fields;
  String fromSql();
  _LinqTemporaryModel<T> create(Map<String, dynamic> data);

  _LinqPseudoClass<T, TDataType> createPseudoClass<TDataType>({String prefix = "", _LinqTemporaryModel<T>? model});

  @override
  _LinqPseudoClass<E, F>? createReverse<E, F>({String prefix = "", Object? key, _LinqTemporaryModel? model});

  @override
  LinqSet<T> take(int count) {
    _take = count;
    return this;
  }

  @override
  LinqSet<T> skip(int count) {
    _skip = count;
    return this;
  }

  @override
  LinqSet<T> descending() {
    _descending = true;
    return this;
  }

  @override
  LinqSet<T> asc() {
    _descending = false;
    return this;
  }

  @override
  LinqSet<T> orderBy<E>(E Function(LinqPseudoClass<T, T> model) by) {
    final fields = createPseudoClass<T>().selectFields(by);
    _orderBy = fields.lastWhereOrNull((element) => element.fieldType == E);
    assert(_orderBy != null);
    assert(
      () {
        return fields.any(
          (element) => element.modelType == _orderBy!.modelType && element.name == _orderBy!.name,
        );
      }(),
    );
    return this;
  }

  @override
  LinqSet<T> where(LinqWhere Function(LinqWherePseudoClass<T, T> model) by) {
    LinqWherePseudoClass<T, T> pseudo = _LinqWherePseudoClass<T, T>(context: context, pseudoClass: createPseudoClass());
    _where = _where?.and(by(pseudo)) ?? by(pseudo);
    return this;
  }

  @override
  LinqSet<E> select<E extends Object>(E Function(LinqPseudoClass<T, T> model) select) {
    final queryFields = createPseudoClass<T>().selectFields(select);
    return _LinqSelectSet<E, T>(
      this,
      (data) => select(createPseudoClass(model: data)),
      queryFields,
    )
      .._descending = _descending
      .._skip = _skip
      .._take = _take
      .._where = _where
      .._orderBy = _orderBy
      .._args = _args;
  }

  @override
  LinqSet<G> join<E extends Object, F, G extends Object>(
    LinqSet<E> other, {
    required JoinOnResult<T, E, F, G> Function(LinqJoinOnPseudoClass<T, T> p0, LinqJoinOnPseudoClass<E, E> p1) on,
  }) {
    assert(other is _LinqContextSet);
    final joinResult = on(
      _LinqJoinOnPseudoClass<T, T>(context, createPseudoClass()),
      _LinqJoinOnPseudoClass<E, E>(context, (other as _LinqContextSet<E>).createPseudoClass()),
    );
    return _LinqJoinSet<T, E, F, G>(
      this,
      other,
      joinResult,
      context: context,
    );
  }

  @override
  Future<int> count([LinqWhere Function(LinqWherePseudoClass<T, T> e)? where]) {
    if (where != null) {
      this.where(where);
    }
    String sql = 'SELECT count(*) FROM ${fromSql()} AS $alias';
    if (_where != null) {
      sql += ' WHERE ${_where!.toSql(alias: alias)}';
    }
    if (_orderBy != null) {
      sql += ' ORDER BY $alias.`${_orderBy!.dbName}` ${_descending ? 'DESC' : 'ASC'}';
    }
    if (_take != null) {
      sql += ' LIMIT $_take';
    }
    if (_skip != null) {
      sql += ' OFFSET $_skip';
    }
    return context.count(sql, args());
  }

  @override
  Future<T> first([LinqWhere Function(LinqWherePseudoClass<T, T> e)? where]) async {
    if (where != null) {
      this.where(where);
    }
    final object = await context.query(toSql(), args()).then((value) => create(value.first));
    return object.model;
  }

  @override
  Future<T?> firstOrNull([LinqWhere Function(LinqWherePseudoClass<T, T> e)? where]) async {
    if (where != null) {
      this.where(where);
    }
    final result = await context.query(toSql(), args());
    return result.isNotEmpty ? create(result.first).model : null;
  }

  @override
  Future<List<T>> toList() async {
    final result = await context.query(toSql(), args());
    final dataResult = result.map((e) => create(e).model).toList();
    return dataResult;
  }

  @override
  String toSql() {
    String sql = 'SELECT ${fields.map((e) => "`$alias`.`${e.dbName}`").join(', ')} FROM ${fromSql()} AS `$alias`';
    if (_where != null) {
      sql += ' WHERE ${_where!.toSql(alias: alias)}';
    }
    if (_orderBy != null) {
      sql += ' ORDER BY `$alias`.`${_orderBy!.dbName}` ${_descending ? 'DESC' : 'ASC'}';
    }
    if (_take != null) {
      sql += ' LIMIT $_take';
    }
    if (_skip != null) {
      sql += ' OFFSET $_skip';
    }
    return sql;
  }

  List args() => [..._args, ...(_where?.args ?? [])];
}

class _LinqSelectSet<T extends Object, E extends Object> extends _LinqContextSet<T> {
  _LinqSelectSet(
    this.sourceSet,
    this.factory,
    this.fields,
  ) : super(context: sourceSet.context);
  final _LinqContextSet<E> sourceSet;
  final T Function(_LinqTemporaryModel<E> data) factory;
  @override
  final List<QueryModelFieldDescriptor> fields;

  @override
  _LinqPseudoClass<T, TDataType> createPseudoClass<TDataType>({String prefix = "", _LinqTemporaryModel<T>? model}) {
    return createReverse<T, TDataType>(prefix: prefix, model: model) ??
        _LinqPseudoClass<T, TDataType>(
          context: context,
          prefix: prefix,
          model: model,
          reverseDelegate: this,
        );
  }

  @override
  _LinqPseudoClass<F, G>? createReverse<F, G>({String prefix = "", Object? key, _LinqTemporaryModel? model}) {
    return sourceSet.createReverse<F, G>(prefix: prefix, key: key, model: model);
  }

  @override
  _LinqTemporaryModel<T> create(Map<String, dynamic> data) {
    final sourceCreate = sourceSet.create(data);
    final result = _LinqTemporaryModel(factory(sourceCreate));
    result.temporaryModels[sourceSet] = sourceCreate;
    return result;
  }

  @override
  String fromSql() {
    return sourceSet.fromSql();
  }
}

class _LinqJoinSet<T extends Object, E extends Object, F, G extends Object> extends _LinqContextSet<G> {
  _LinqJoinSet(this.left, this.right, this.joinOn, {required super.context}) {
    leftAlias = left.alias;
    rightAlias = right.alias;
    final _LinqPseudoClass<T, T> leftPseudoClass = left.createPseudoClass();
    final _LinqPseudoClass<E, E> rightPseudoClass = right.createPseudoClass();
    leftFields = leftPseudoClass.selectFields((p0) {
      joinOn.select(p0, rightPseudoClass);
    });
    rightFields = rightPseudoClass.selectFields((p0) {
      joinOn.select(leftPseudoClass, p0);
    });
    fields = [
      ...leftFields.map((e) => e.copyWith(dbName: "${leftAlias}_${e.dbName}")),
      ...rightFields.map((e) => e.copyWith(dbName: "${rightAlias}_${e.dbName}")),
    ];
    _args.addAll(
      [
        ...left.args(),
        ...right.args(),
      ],
    );
  }
  final _LinqContextSet<T> left;
  final _LinqContextSet<E> right;
  final JoinOnResult<T, E, F, G> joinOn;
  late final String leftAlias;
  late final String rightAlias;
  late final List<QueryModelFieldDescriptor> leftFields;
  late final List<QueryModelFieldDescriptor> rightFields;
  @override
  late final List<QueryModelFieldDescriptor> fields;

  @override
  _LinqPseudoClass<G, TDataType> createPseudoClass<TDataType>({String prefix = "", _LinqTemporaryModel<G>? model}) {
    final reverse = createReverse<G, TDataType>(prefix: prefix, model: model);
    if (reverse != null) {
      reverse.reverseDelegate = this;
      return reverse;
    }
    return _LinqPseudoClass<G, TDataType>(
      context: context,
      prefix: prefix,
      model: model,
      reverseDelegate: this,
    );
  }

  @override
  _LinqPseudoClass<H, I>? createReverse<H, I>({String prefix = "", Object? key, _LinqTemporaryModel? model}) {
    // final ({T left, E right})? reverseObjects = model == null ? null : _joinCreateObjects[Object.hash(this, model)];
    // if (H == T && key == left.key) {
    //   return left.createPseudoClass<I>(
    //     prefix: [leftAlias, if (prefix.isNotEmpty) prefix].join("_"),
    //     model: model?.findChild(key: key), // reverseObjects?.left,
    //   ) as _LinqPseudoClass<H, I>;
    // }
    // if (H == E && key == right.key) {
    //   return right.createPseudoClass<I>(
    //     prefix: [rightAlias, if (prefix.isNotEmpty) prefix].join("_"),
    //     model: model?.findChild(key: key), // reverseObjects?.left,
    //   ) as _LinqPseudoClass<H, I>;
    // }
    final result = left.createReverse<H, I>(
          prefix: [leftAlias, if (prefix.isNotEmpty) prefix].join("_"),
          key: key,
          model: model,
        ) ??
        right.createReverse<H, I>(
          prefix: [rightAlias, if (prefix.isNotEmpty) prefix].join("_"),
          key: key,
          model: model,
        );
    return result;
  }

  @override
  _LinqTemporaryModel<G> create(Map<String, dynamic> data) {
    Map<String, dynamic> leftData = {};
    Map<String, dynamic> rightData = {};
    for (var field in fields) {
      if (field.dbName.startsWith(leftAlias)) {
        leftData[field.dbName.substring(leftAlias.length + 1)] = data[field.dbName];
      } else {
        rightData[field.dbName.substring(rightAlias.length + 1)] = data[field.dbName];
      }
    }
    final leftObject = left.create(leftData);
    final rightObject = right.create(rightData);
    final result = joinOn.select(
      left.createPseudoClass(model: leftObject),
      right.createPseudoClass(model: rightObject),
    );
    // _joinCreateObjects[Object.hash(this, result)] = (left: leftObject, right: rightObject);
    // if (result is T && result is LinqModel) {
    //   (result as LinqModel).linqObject = (leftObject as LinqModel).linqObject;
    // }
    final model = _LinqTemporaryModel(result);
    model.temporaryModels[left] = leftObject;
    model.temporaryModels[right] = rightObject;
    return model;
  }

  @override
  String fromSql() {
    StringBuffer sb = StringBuffer();
    sb.write("(SELECT ");
    List<String> fields = [];
    for (var field in leftFields) {
      fields.add("`$leftAlias`.`${field.dbName}` AS `${leftAlias}_${field.dbName}`");
    }
    for (var field in rightFields) {
      fields.add("`$rightAlias`.`${field.dbName}` AS `${rightAlias}_${field.dbName}`");
    }
    sb.write(fields.join(", "));
    sb.write(" FROM ${left.fromSql()} AS `$leftAlias` ");
    sb.write(switch (joinOn.type) {
      QueryJoinType.inner => "INNER JOIN",
      QueryJoinType.left => "LEFT JOIN",
      QueryJoinType.right => "RIGHT JOIN",
    });
    sb.write(" ${right.fromSql()} AS `$rightAlias` ");
    sb.write("ON `$leftAlias`.`${joinOn.left.dbName}` = `$rightAlias`.`${joinOn.right.dbName}`");
    if (left._where != null || right._where != null) {
      sb.write(" WHERE ");
      if (left._where != null) {
        sb.write(left._where!.toSql(alias: leftAlias));
      }
      if (right._where != null) {
        if (left._where != null) {
          sb.write(" AND ");
        }
        sb.write(right._where!.toSql(alias: rightAlias));
      }
    }
    sb.write(")");
    return sb.toString();
  }
}

class _LinqEntitySet<T extends LinqModel> extends _LinqContextSet<T> {
  _LinqEntitySet(this.entity, {required super.context});
  final LinqEntity<T> entity;
  @override
  _LinqPseudoClass<T, TDataType> createPseudoClass<TDataType>({String prefix = "", _LinqTemporaryModel<T>? model}) {
    return _LinqPseudoClass<T, TDataType>(
      context: context,
      reverseDelegate: this,
      prefix: prefix,
      entity: entity,
      model: model,
    );
  }

  @override
  _LinqPseudoClass<E, F>? createReverse<E, F>({String prefix = "", Object? key, _LinqTemporaryModel? model}) {
    if (E == T && key == this.key) {
      return _LinqPseudoClass<E, F>(
        context: context,
        reverseDelegate: this,
        prefix: prefix,
        model: model?.findChild<E>(key: key),
        entity: entity,
      );
    }
    return null;
  }

  @override
  _LinqTemporaryModel<T> create(Map<String, dynamic> data) {
    final object = entity.create();
    List<QueryModelFieldDescriptor> hasValueFields = [];
    for (var element in entity.fields()) {
      if (data[element.dbName] != null) {
        element.setDbValue(object, data[element.dbName]);
        hasValueFields.add(element);
      }
    }
    object.linqObject = _LinqObject<T>._(
      object: object,
      entity: entity,
      context: context,
      hasValueFields: hasValueFields,
    );
    return _LinqTemporaryModel(object);
  }

  @override
  List<QueryModelFieldDescriptor> get fields => entity.fields();

  @override
  String fromSql() {
    return "`${entity.tableName()}`";
  }
}

abstract class LinqTransactionContext {
  Future<int> execute(String sql, List args);
  void rollback();
}

class _LinqContextInsertObject<T extends LinqModel> {
  _LinqContextInsertObject(this.entity, this.object);
  final LinqEntity<T> entity;
  final T object;
}

class _LinqContextUpdateObject<T extends LinqModel> {
  _LinqContextUpdateObject(this.entity, this.fields, this.object);
  final LinqEntity<T> entity;
  final List<LinqPseudoClassUpdateField> fields;
  final T object;
}

class _LinqContextDeleteObject<T extends LinqModel> {
  _LinqContextDeleteObject(this.entity, this.object);
  final LinqEntity<T> entity;
  final T object;
}

abstract class LinqContext {
  String? _currentPrefix;
  String _nextPrefix() {
    _currentPrefix = nextPrefix(_currentPrefix);
    prefixHistory.add(_currentPrefix!);
    return _currentPrefix!;
  }

  @visibleForTesting
  List<String> prefixHistory = [];

  LinqEntity<T> modelEntity<T extends LinqModel>();
  LinqSet<T> entitySet<T extends LinqModel>() {
    LinqEntity<T> entity = modelEntity<T>();
    final set = _LinqEntitySet<T>(entity, context: this);
    _currentEntity[T] = _currentEntity[T] ?? [];
    _currentEntity[T]!.add(set);
    return set;
  }

  void didUpdateModel<T>(LinqPseudoClass<T, T> pClassModel, T model) {}

  final Map<Type, List<_LinqEntitySet>> _currentEntity = {};
  final List<_LinqContextInsertObject> _inserts = [];
  final List<_LinqContextUpdateObject> _updates = [];
  final List<_LinqContextDeleteObject> _deletes = [];

  void _updateEntity<T extends LinqModel>(LinqEntity<T> entity, List<LinqPseudoClassUpdateField> fields, T object) {
    _updates.add(_LinqContextUpdateObject(entity, fields, object));
  }

  void _deleteEntity<T extends LinqModel>(LinqEntity<T> entity, T object) {
    _deletes.add(_LinqContextDeleteObject(entity, object));
  }

  void _insertEntity<T extends LinqModel>(LinqEntity<T> entity, T object) {
    _inserts.add(_LinqContextInsertObject(entity, object));
  }

  void add<T extends LinqModel>(T object) {
    LinqEntity<T> entity = modelEntity<T>();
    _insertEntity(entity, object);
  }

  Future<List<Map<String, dynamic>>> query(String sql, List args);
  Future<int> count(String sql, List args);
  Future<T?> transaction<T>(Future<T> Function(LinqTransactionContext context) block);

  Future<int?> saveChanges() {
    return transaction<int?>(
      (context) async {
        List<Future<int>> futures = [];
        for (var insert in _inserts) {
          final fields = insert.entity.fields();
          final values = fields.map((e) => e.getDbValue(insert.object)).toList();
          final sql = "INSERT INTO `${insert.entity.tableName()}` (${fields.map((e) => e.dbName).join(", ")}) VALUES (${fields.map((e) => "?").join(", ")})";
          futures.add(context.execute(sql, values));
        }
        for (var update in _updates) {
          final fields = update.fields;
          if (fields.isEmpty) continue;
          final values = fields.map((e) => e.field.codec?.encoder.convert(e.newValue) ?? e.newValue).toList();
          final primaryKeys = update.entity.fields().where((element) => element.isPrimaryKey).toList();
          final whereValues = primaryKeys.map(
            (e) {
              return e.getDbValue(update.object);
            },
          ).toList();
          final sql = "UPDATE `${update.entity.tableName()}` SET ${fields.map((e) => "${e.field.dbName} = ?").join(", ")} WHERE ${primaryKeys.map((e) => "`${e.dbName}` = ?").join(" AND ")}";
          futures.add(context.execute(sql, [...values, ...whereValues]));
        }
        for (var delete in _deletes) {
          final primaryKeys = delete.entity.fields().where((element) => element.isPrimaryKey).toList();
          final values = primaryKeys.map((e) => e.getDbValue(delete.object)).toList();
          final sql = "DELETE FROM `${delete.entity.tableName()}` WHERE ${primaryKeys.map((e) => "${e.dbName} = ?").join(" AND ")}";
          futures.add(context.execute(sql, values));
        }
        final result = (await Future.wait(futures)).sum;
        _inserts.clear();
        _updates.clear();
        _deletes.clear();
        return result;
      },
    );
  }
}
