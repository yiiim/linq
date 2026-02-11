import 'annotation/linq.dart';

// Interface for providing SQL dialect-specific functionality
abstract class ParameterPlaceholderProvider {
  String parameterPlaceholder(int index);
  String quoteIdentifier(String name);
}

abstract class QueryDescriptor<T> {
  String toSql();
}

T defaultValue<T>() {
  throw "";
}

class QueryModelFieldDescriptor<TModelType, TValueType> {
  QueryModelFieldDescriptor({
    required this.name,
    required this.dbName,
    required this.defaultValue,
    this.isPrimaryKey = false,
    this.isAutoIncrement = false,
    this.get,
    this.set,
    this.codec,
  });
  TValueType Function(TModelType model)? get;
  void Function(TModelType model, TValueType value)? set;

  final bool isPrimaryKey;
  final bool isAutoIncrement;
  final String name;
  final String dbName;
  final DataFieldCodec? codec;
  final TValueType defaultValue;
  Type get modelType => TModelType;
  Type get fieldType => TValueType;

  dynamic getDbValue(TModelType model) {
    final value = get!(model);
    if (value == null) {
      return null;
    }
    return codec?.encoder.convert(value) ?? value;
  }

  void setDbValue(TModelType model, dynamic value) {
    set!(model, codec?.decoder.convert(value) ?? value);
  }

  QueryModelFieldDescriptor<TModelType, TValueType> copyWith({String? name, String? dbName, bool? isPrimaryKey, bool? isAutoIncrement}) {
    return QueryModelFieldDescriptor<TModelType, TValueType>(
      isPrimaryKey: isPrimaryKey ?? this.isPrimaryKey,
      isAutoIncrement: isAutoIncrement ?? this.isAutoIncrement,
      name: name ?? this.name,
      dbName: dbName ?? this.dbName,
      defaultValue: defaultValue,
      get: get,
      set: set,
      codec: codec,
    );
  }
}

enum QueryJoinType {
  inner,
  left,
  right,
}

enum LinqWhereOperator {
  isNull,
  isNotNull,
  equal,
  notEqual,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  like,
  notLike,
  inList,
  notInList;
}

enum LinqWhereLikeOperator {
  start,
  end,
  both,
}

enum LinqWhereJoinOperator {
  and,
  or,
}

abstract class LinqWherePropertyField<T, E> {
  LinqWhere equalValue(E? value);
  LinqWhere likeValue(E value,{LinqWhereLikeOperator likeOperator = LinqWhereLikeOperator.both});
  LinqWhere notEqualValue(E? value);
  LinqWhere equal<F>(LinqWherePropertyField<F, E> other);
  LinqWhere notEqual<F>(LinqWherePropertyField<F, E> other);
  LinqWhere inValues(List<E> values);
  LinqWhere notInValues(List<E> values);
  LinqWhere lessThanValue(E value);
  LinqWhere lessThanOrEqualValue(E value);
  LinqWhere greaterThanValue(E value);
  LinqWhere greaterThanOrEqualValue(E value);
}

abstract class LinqWhere {
  List get args;
  String toSql({required String alias, required ParameterPlaceholderProvider context, int paramIndex = 1});

  LinqWhere group();
  LinqWhere and(LinqWhere other);
  LinqWhere or(LinqWhere other);
}
