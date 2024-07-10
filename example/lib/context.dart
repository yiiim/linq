import 'package:linq/linq.dart';
import 'package:sqlite3/sqlite3.dart';
import 'model.dart';

part 'context.g.dart';

List<String> studentModelColumns = ["id", "name", "age", "class_id"];
String studentModelTable = "StudentModel";
List<StudentModel> studentDatas = [
  StudentModel()
    ..id = "1"
    ..name = "Tom"
    ..age = 18
    ..classId = "1",
  StudentModel()
    ..id = "2"
    ..name = "Jerry"
    ..age = 19
    ..classId = "1",
  StudentModel()
    ..id = "3"
    ..age = 20
    ..classId = "2",
  StudentModel()
    ..id = "4"
    ..name = "Spike"
    ..age = 21
    ..classId = "2",
];

List<String> classModelColumns = ["id", "name"];
String classModelTable = "ClassModel";
List<ClassModel> classDatas = [
  ClassModel()
    ..id = "1"
    ..name = "Class 1",
  ClassModel()
    ..id = "2"
    ..name = "Class 2",
];

List<String> courseModelColumns = ["id", "name", "date"];
String courseModelTable = "CourseModel";
List<CourseModel> courseDatas = [
  CourseModel()
    ..id = "1"
    ..name = "Math"
    ..date = DateTime.now(),
  CourseModel()
    ..id = "2"
    ..name = "English"
    ..date = DateTime.now(),
];

List<String> courseUserModelColumns = ["id", "user_id", "course_id"];
String courseUserModelTable = "CourseUserModel";
List<CourseUserModel> courseUserDatas = [
  CourseUserModel()
    ..id = "1"
    ..userId = "1"
    ..courseId = "1",
  CourseUserModel()
    ..id = "2"
    ..userId = "2"
    ..courseId = "1",
  CourseUserModel()
    ..id = "3"
    ..userId = "3"
    ..courseId = "2",
];

@LinqContextObject(
  [StudentModel, ClassModel, CourseModel, CourseUserModel],
)
class TestContext extends LinqContext with _TestContextMixin implements LinqTransactionContext {
  TestContext(this.database);
  final Database database;
  List<String> sqlsHistory = [];
  List argsHistory = [];

  @override
  Future<int> count(String sql, List args) {
    sqlsHistory.add(sql);
    argsHistory.add(args);
    return Future.value(database.select(sql, args).length);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String sql, List args) {
    sqlsHistory.add(sql);
    argsHistory.add(args);
    return Future.value(database.select(sql, args));
  }

  @override
  Future<T?> transaction<T>(Future<T> Function(LinqTransactionContext context) block) {
    return block(this);
  }

  @override
  Future<int> execute(String sql, List args) {
    sqlsHistory.add(sql);
    argsHistory.add(args);
    database.execute(sql, args);
    return Future.value(database.updatedRows);
  }

  @override
  void rollback() {}
}
