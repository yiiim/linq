import 'pseudo.dart';

abstract class ModelListener<T> {
  void didUpdate(LinqPseudoClass<T, T> pClassModel, T model);
  void didRmove(T model);
}

abstract class LinqModel {
  LinqModel();

  late final LinqObject linqObject;

  void remove() => linqObject.remove();
  void addListener(ModelListener listener) => linqObject.addListener(listener);
  void removeListener(ModelListener listener) => linqObject.removeListener(listener);
}

abstract class LinqObject<T> {
  void update(void Function(LinqPseudoClass<T, T>) block);
  void remove();

  void addListener(ModelListener<T> listener);
  void removeListener(ModelListener<T> listener);
}
