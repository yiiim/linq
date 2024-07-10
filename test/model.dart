import 'dart:convert';

import 'package:linq/linq.dart';

part 'model.g.dart';

class DateTimeCodec extends DataFieldCodec<DateTime, int> {
  const DateTimeCodec();

  @override
  Converter<int, DateTime> get decoder => DateTimeCodecDecoder();

  @override
  Converter<DateTime, int> get encoder => DateTimeCodecEncoder();

  @override
  DateTime get defaultValue => DateTime.now();
}

class DateTimeCodecDecoder extends Converter<int, DateTime> {
  @override
  DateTime convert(int input) {
    return DateTime.fromMillisecondsSinceEpoch(input);
  }
}

class DateTimeCodecEncoder extends Converter<DateTime, int> {
  @override
  int convert(DateTime input) {
    return input.millisecondsSinceEpoch;
  }
}

@Linq()
class StudentModel extends LinqModel {
  StudentModel();

  @LinqColum(primaryKey: true)
  late String id;
  String? name;
  late int age;
  late String classId;

  @override
  bool operator ==(Object other) {
    return other is StudentModel && other.id == id && other.name == name && other.age == age && other.classId == classId;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, age, classId);
  }
}

@Linq()
class ClassModel extends LinqModel {
  ClassModel();
  @LinqColum(primaryKey: true)
  late String id;
  late String name;

  @override
  bool operator ==(Object other) {
    return other is ClassModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode {
    return Object.hash(id, name);
  }
}

@Linq()
class CourseModel extends LinqModel {
  CourseModel();
  @LinqColum(primaryKey: true)
  late String id;
  late String name;
  @LinqColum(codec: DateTimeCodec())
  late DateTime date;

  @override
  bool operator ==(Object other) {
    return other is CourseModel && other.id == id && other.name == name && other.date == date;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, date);
  }
}

@Linq()
class CourseUserModel extends LinqModel {
  CourseUserModel();
  @LinqColum(primaryKey: true)
  late String id;
  late String courseId;
  late String userId;

  @override
  bool operator ==(Object other) {
    return other is CourseUserModel && other.id == id && other.courseId == courseId && other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, courseId, userId);
  }
}
