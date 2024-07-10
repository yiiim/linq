import 'package:example/context.dart';
import 'package:example/model.dart';
import 'package:sqlite3/sqlite3.dart';

void main(List<String> arguments) async {
  final Database database = sqlite3.openInMemory();
  database.execute('''
      CREATE TABLE $studentModelTable (
        id TEXT PRIMARY KEY,
        name TEXT,
        age INTEGER,
        class_id TEXT
      )
    ''');
  TestContext context = TestContext(database);
  StudentModel student = StudentModel()
    ..id = "1"
    ..name = "Tom"
    ..age = 18
    ..classId = "1";
  context.add(student);
  await context.saveChanges();
  final query = await context.studentModel.where((e) => e.id.equalValue("1")).firstOrNull();
  query!.update(
    (model) {
      model.age = 19;
    },
  );
  await context.saveChanges();
  final query2 = await context.studentModel.where((e) => e.id.equalValue("1")).firstOrNull();
  print(query2!.age);
  query2.remove();
  await context.saveChanges();
  final query3 = await context.studentModel.where((e) => e.id.equalValue("1")).firstOrNull();
  print(query3);
}
