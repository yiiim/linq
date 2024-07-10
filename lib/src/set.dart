import 'pseudo.dart';
import 'query_descriptor.dart';

abstract class LinqSet<T extends Object> {
  Object? key;
  LinqSet<T> take(int count);
  LinqSet<T> skip(int count);
  LinqSet<T> orderBy<E>(E Function(LinqPseudoClass<T, T> e) by);
  LinqSet<T> descending();
  LinqSet<T> asc();
  LinqSet<T> where(LinqWhere Function(LinqWherePseudoClass<T, T> e) where);
  LinqSet<E> select<E extends Object>(E Function(LinqPseudoClass<T, T> e) select);
  LinqSet<G> join<E extends Object, F, G extends Object>(
    LinqSet<E> other, {
    required JoinOnResult<T, E, F, G> Function(LinqJoinOnPseudoClass<T, T> t1, LinqJoinOnPseudoClass<E, E> t2) on,
  });

  Future<T?> firstOrNull([LinqWhere Function(LinqWherePseudoClass<T, T> e)? where]);
  Future<T> first([LinqWhere Function(LinqWherePseudoClass<T, T> e)? where]);
  Future<int> count([LinqWhere Function(LinqWherePseudoClass<T, T> e)? where]);
  Future<List<T>> toList();

  Future<bool> any([LinqWhere Function(LinqWherePseudoClass<T, T> e)? where]) async {
    return (await count(where)) > 0;
  }
}