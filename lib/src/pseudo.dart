import 'query_descriptor.dart';

class LinqPseudoClassUpdateField<T, E> {
  LinqPseudoClassUpdateField(this.field, this.newValue);
  final QueryModelFieldDescriptor<T, E> field;
  final E newValue;
}

abstract class LinqPseudoClass<TModelType, TDataType> {
  TValueType get<TValueType>(String name);
  void set<TValueType>(String name, TValueType newValue);

  TModelType selectAll();
  LinqPseudoClass<TReverseModelType, TDataType> reverse<TReverseModelType>({Object? key});
}

abstract class LinqWherePseudoClass<TModelType, TDataType> {
  LinqWherePropertyField<TDataType, TValueType> whereField<TValueType>(String name);
  LinqWherePseudoClass<TReverseModelType, TDataType> reverse<TReverseModelType>({Object? key});
}

abstract class LinqJoinOnPseudoClass<TModelType, TDataType> {
  JoinOnItem<TDataType, TValueType> joinField<TValueType>(String name);

  LinqJoinOnPseudoClass<TReverseModelType, TDataType> reverse<TReverseModelType>({Object? key});
}

abstract class JoinOnItem<TDataType, TValueType> {
  JoinOnSelectResult<TDataType, TRightDataType, TValueType> on<TRightDataType>(
    JoinOnItem<TRightDataType, TValueType> other, {
    QueryJoinType type = QueryJoinType.inner,
  });
}

abstract class JoinOnSelectResult<TLeftDataType, TRightDataType, TOnValueType> {
  JoinOnResult<TLeftDataType, TRightDataType, TOnValueType, TSelectDataType> select<TSelectDataType>(
    TSelectDataType Function(LinqPseudoClass<TLeftDataType, TLeftDataType> p0, LinqPseudoClass<TRightDataType, TRightDataType> p1) select,
  );
}

class JoinOnResult<TLeftDataType, TRightDataType, TOnValueType, TSelectDataType> {
  JoinOnResult(this.left, this.right, this.select, {this.type = QueryJoinType.left});
  final QueryJoinType type;
  final QueryModelFieldDescriptor<TLeftDataType, TOnValueType> left;
  final QueryModelFieldDescriptor<TRightDataType, TOnValueType> right;
  final TSelectDataType Function(LinqPseudoClass<TLeftDataType, TLeftDataType> p0, LinqPseudoClass<TRightDataType, TRightDataType> p1) select;
}
