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
  database.execute('''
      CREATE TABLE $classModelTable (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');
  print("-------------Insert---------------------");
  TestContext context = TestContext(database);
  StudentModel student = StudentModel()
    ..id = "1"
    ..name = "Tom"
    ..age = 18
    ..classId = "1";
  context.add(student);

  StudentModel student2 = StudentModel()
    ..id = "2"
    ..name = "Jerry"
    ..age = 19
    ..classId = "1";
  context.add(student2);

  ClassModel classModel = ClassModel()
    ..id = "1"
    ..name = "Class 1";
  context.add(classModel);
  await context.saveChanges();

  print("---------------Select-------------------");
  final query = await context.studentModel.where((e) => e.id.equalValue("1")).firstOrNull();
  print(query);
  final select = await context.studentModel.select((e) => (e.age, e.name)).toList();
  print(select);
  final joinQuery = await context.studentModel
      .join(
        context.classModel,
        on: (t1, t2) => t1.classId.on(t2.id).select(
              (t1, t2) => (
                student: t1.selectAll(),
                cls: t2.selectAll(),
              ),
            ),
      )
      .toList();
  for (var element in joinQuery) {
    print("student: ${element.student}, class: ${element.cls}");
  }

  print("---------------Update-------------------");
  query!.update(
    (model) {
      model.age = 19;
    },
  );
  await context.saveChanges();
  final query2 = await context.studentModel.where((e) => e.id.equalValue("1")).firstOrNull();
  print(query2!.age);

  print("---------------Delete-------------------");
  query2.remove();
  await context.saveChanges();
  final query3 = await context.studentModel.where((e) => e.id.equalValue("1")).firstOrNull();
  print(query3);
}
