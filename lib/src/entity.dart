import 'linq_model.dart';
import 'query_descriptor.dart';

abstract class LinqEntity<T extends LinqModel> {
  T create();
  String tableName();
  List<QueryModelFieldDescriptor> fields();
}
