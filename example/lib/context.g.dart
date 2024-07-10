// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context.dart';

// **************************************************************************
// LinqContextGenerator
// **************************************************************************

mixin _TestContextMixin on LinqContext {
  LinqSet<StudentModel> get studentModel => entitySet<StudentModel>();
  LinqSet<ClassModel> get classModel => entitySet<ClassModel>();
  LinqSet<CourseModel> get courseModel => entitySet<CourseModel>();
  LinqSet<CourseUserModel> get courseUserModel => entitySet<CourseUserModel>();
  @override
  LinqEntity<T> modelEntity<T extends LinqModel>() => switch (T) {
        StudentModel => StudentModelEntity() as LinqEntity<T>,
        ClassModel => ClassModelEntity() as LinqEntity<T>,
        CourseModel => CourseModelEntity() as LinqEntity<T>,
        CourseUserModel => CourseUserModelEntity() as LinqEntity<T>,
        _ => throw Exception('Unknown entity type: $T'),
      };
}
