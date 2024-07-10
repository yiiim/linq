// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// LinqGenerator
// **************************************************************************

extension LinqStudentModelExtension<T> on StudentModel {
  void update(
          void Function(LinqPseudoClass<StudentModel, StudentModel> model)
              block) =>
      (linqObject as LinqObject<StudentModel>).update(block);
}

extension LinqJoinOnPseudoClassStudentModelExtension<T>
    on LinqJoinOnPseudoClass<StudentModel, T> {
  JoinOnItem<T, String> get id => joinField<String>('id');
  JoinOnItem<T, String?> get name => joinField<String?>('name');
  JoinOnItem<T, int> get age => joinField<int>('age');
  JoinOnItem<T, String> get classId => joinField<String>('classId');
}

class StudentModelEntity extends LinqEntity<StudentModel> {
  @override
  StudentModel create() => StudentModel();

  @override
  List<QueryModelFieldDescriptor> fields() => [
        QueryModelFieldDescriptor<StudentModel, String>(
            name: "id",
            dbName: "id",
            defaultValue: '',
            isPrimaryKey: true,
            get: (model) => model.id,
            set: (model, value) => model.id = value,
            codec: null),
        QueryModelFieldDescriptor<StudentModel, String?>(
            name: "name",
            dbName: "name",
            defaultValue: null,
            isPrimaryKey: false,
            get: (model) => model.name,
            set: (model, value) => model.name = value,
            codec: null),
        QueryModelFieldDescriptor<StudentModel, int>(
            name: "age",
            dbName: "age",
            defaultValue: 0,
            isPrimaryKey: false,
            get: (model) => model.age,
            set: (model, value) => model.age = value,
            codec: null),
        QueryModelFieldDescriptor<StudentModel, String>(
            name: "classId",
            dbName: "class_id",
            defaultValue: '',
            isPrimaryKey: false,
            get: (model) => model.classId,
            set: (model, value) => model.classId = value,
            codec: null)
      ];

  @override
  String tableName() => 'StudentModel';
}

extension LinqPseudoClassStudentModelExtension<T>
    on LinqPseudoClass<StudentModel, T> {
  String get id => get<String>("id");
  set id(String value) {
    set<String>("id", value);
  }

  String? get name => get<String?>("name");
  set name(String? value) {
    set<String?>("name", value);
  }

  int get age => get<int>("age");
  set age(int value) {
    set<int>("age", value);
  }

  String get classId => get<String>("classId");
  set classId(String value) {
    set<String>("classId", value);
  }

  StudentModel select() {
    return StudentModel()
      ..id = id
      ..name = name
      ..age = age
      ..classId = classId;
  }
}

extension LinqWherePseudoClassStudentModelExtension<T>
    on LinqWherePseudoClass<StudentModel, T> {
  LinqWherePropertyField<T, String> get id => whereField<String>('id');
  LinqWherePropertyField<T, String?> get name => whereField<String?>('name');
  LinqWherePropertyField<T, int> get age => whereField<int>('age');
  LinqWherePropertyField<T, String> get classId =>
      whereField<String>('classId');
}

extension LinqClassModelExtension<T> on ClassModel {
  void update(
          void Function(LinqPseudoClass<ClassModel, ClassModel> model) block) =>
      (linqObject as LinqObject<ClassModel>).update(block);
}

extension LinqJoinOnPseudoClassClassModelExtension<T>
    on LinqJoinOnPseudoClass<ClassModel, T> {
  JoinOnItem<T, String> get id => joinField<String>('id');
  JoinOnItem<T, String> get name => joinField<String>('name');
}

class ClassModelEntity extends LinqEntity<ClassModel> {
  @override
  ClassModel create() => ClassModel();

  @override
  List<QueryModelFieldDescriptor> fields() => [
        QueryModelFieldDescriptor<ClassModel, String>(
            name: "id",
            dbName: "id",
            defaultValue: '',
            isPrimaryKey: true,
            get: (model) => model.id,
            set: (model, value) => model.id = value,
            codec: null),
        QueryModelFieldDescriptor<ClassModel, String>(
            name: "name",
            dbName: "name",
            defaultValue: '',
            isPrimaryKey: false,
            get: (model) => model.name,
            set: (model, value) => model.name = value,
            codec: null)
      ];

  @override
  String tableName() => 'ClassModel';
}

extension LinqPseudoClassClassModelExtension<T>
    on LinqPseudoClass<ClassModel, T> {
  String get id => get<String>("id");
  set id(String value) {
    set<String>("id", value);
  }

  String get name => get<String>("name");
  set name(String value) {
    set<String>("name", value);
  }

  ClassModel select() {
    return ClassModel()
      ..id = id
      ..name = name;
  }
}

extension LinqWherePseudoClassClassModelExtension<T>
    on LinqWherePseudoClass<ClassModel, T> {
  LinqWherePropertyField<T, String> get id => whereField<String>('id');
  LinqWherePropertyField<T, String> get name => whereField<String>('name');
}

extension LinqCourseModelExtension<T> on CourseModel {
  void update(
          void Function(LinqPseudoClass<CourseModel, CourseModel> model)
              block) =>
      (linqObject as LinqObject<CourseModel>).update(block);
}

extension LinqJoinOnPseudoClassCourseModelExtension<T>
    on LinqJoinOnPseudoClass<CourseModel, T> {
  JoinOnItem<T, String> get id => joinField<String>('id');
  JoinOnItem<T, String> get name => joinField<String>('name');
  JoinOnItem<T, DateTime> get date => joinField<DateTime>('date');
}

class CourseModelEntity extends LinqEntity<CourseModel> {
  @override
  CourseModel create() => CourseModel();

  @override
  List<QueryModelFieldDescriptor> fields() => [
        QueryModelFieldDescriptor<CourseModel, String>(
            name: "id",
            dbName: "id",
            defaultValue: '',
            isPrimaryKey: true,
            get: (model) => model.id,
            set: (model, value) => model.id = value,
            codec: null),
        QueryModelFieldDescriptor<CourseModel, String>(
            name: "name",
            dbName: "name",
            defaultValue: '',
            isPrimaryKey: false,
            get: (model) => model.name,
            set: (model, value) => model.name = value,
            codec: null),
        QueryModelFieldDescriptor<CourseModel, DateTime>(
            name: "date",
            dbName: "date",
            defaultValue: const DateTimeCodec().defaultValue,
            isPrimaryKey: false,
            get: (model) => model.date,
            set: (model, value) => model.date = value,
            codec: const DateTimeCodec())
      ];

  @override
  String tableName() => 'CourseModel';
}

extension LinqPseudoClassCourseModelExtension<T>
    on LinqPseudoClass<CourseModel, T> {
  String get id => get<String>("id");
  set id(String value) {
    set<String>("id", value);
  }

  String get name => get<String>("name");
  set name(String value) {
    set<String>("name", value);
  }

  DateTime get date => get<DateTime>("date");
  set date(DateTime value) {
    set<DateTime>("date", value);
  }

  CourseModel select() {
    return CourseModel()
      ..id = id
      ..name = name
      ..date = date;
  }
}

extension LinqWherePseudoClassCourseModelExtension<T>
    on LinqWherePseudoClass<CourseModel, T> {
  LinqWherePropertyField<T, String> get id => whereField<String>('id');
  LinqWherePropertyField<T, String> get name => whereField<String>('name');
  LinqWherePropertyField<T, DateTime> get date => whereField<DateTime>('date');
}

extension LinqCourseUserModelExtension<T> on CourseUserModel {
  void update(
          void Function(LinqPseudoClass<CourseUserModel, CourseUserModel> model)
              block) =>
      (linqObject as LinqObject<CourseUserModel>).update(block);
}

extension LinqJoinOnPseudoClassCourseUserModelExtension<T>
    on LinqJoinOnPseudoClass<CourseUserModel, T> {
  JoinOnItem<T, String> get id => joinField<String>('id');
  JoinOnItem<T, String> get courseId => joinField<String>('courseId');
  JoinOnItem<T, String> get userId => joinField<String>('userId');
}

class CourseUserModelEntity extends LinqEntity<CourseUserModel> {
  @override
  CourseUserModel create() => CourseUserModel();

  @override
  List<QueryModelFieldDescriptor> fields() => [
        QueryModelFieldDescriptor<CourseUserModel, String>(
            name: "id",
            dbName: "id",
            defaultValue: '',
            isPrimaryKey: true,
            get: (model) => model.id,
            set: (model, value) => model.id = value,
            codec: null),
        QueryModelFieldDescriptor<CourseUserModel, String>(
            name: "courseId",
            dbName: "course_id",
            defaultValue: '',
            isPrimaryKey: false,
            get: (model) => model.courseId,
            set: (model, value) => model.courseId = value,
            codec: null),
        QueryModelFieldDescriptor<CourseUserModel, String>(
            name: "userId",
            dbName: "user_id",
            defaultValue: '',
            isPrimaryKey: false,
            get: (model) => model.userId,
            set: (model, value) => model.userId = value,
            codec: null)
      ];

  @override
  String tableName() => 'CourseUserModel';
}

extension LinqPseudoClassCourseUserModelExtension<T>
    on LinqPseudoClass<CourseUserModel, T> {
  String get id => get<String>("id");
  set id(String value) {
    set<String>("id", value);
  }

  String get courseId => get<String>("courseId");
  set courseId(String value) {
    set<String>("courseId", value);
  }

  String get userId => get<String>("userId");
  set userId(String value) {
    set<String>("userId", value);
  }

  CourseUserModel select() {
    return CourseUserModel()
      ..id = id
      ..courseId = courseId
      ..userId = userId;
  }
}

extension LinqWherePseudoClassCourseUserModelExtension<T>
    on LinqWherePseudoClass<CourseUserModel, T> {
  LinqWherePropertyField<T, String> get id => whereField<String>('id');
  LinqWherePropertyField<T, String> get courseId =>
      whereField<String>('courseId');
  LinqWherePropertyField<T, String> get userId => whereField<String>('userId');
}
