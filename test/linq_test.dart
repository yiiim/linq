import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'context.dart';
import 'model.dart';

void main() {
  setUpAll(() {
    initDataBase();
  });
  tearDownAll(() {
    disposeDatabase();
  });

  test(
    "test select all columns",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel;
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias`";
      expect(context.sqlsHistory, [sql]);
      expect([[]], context.argsHistory);
      expect(result, studentDatas);
    },
  );

  test(
    "test select part of columns",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.select((e) => [e.id, e.name]);
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT `$alias`.`id`, `$alias`.`name` FROM `$studentModelTable` AS `$alias`";
      expect(context.sqlsHistory, [sql]);
      expect([[]], context.argsHistory);
      expect(result, studentDatas.map((e) => [e.id, e.name]).toList());
    },
  );

  test(
    "test select with where",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.where((e) => e.id.equalValue("1"));
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` WHERE `$alias`.`id` = ?";
      expect(context.sqlsHistory, [sql]);
      expect(
        [
          ["1"]
        ],
        context.argsHistory,
      );
      expect(result, studentDatas.where((e) => e.id == "1").toList());
    },
  );

  test(
    "test select with where notEqualValue",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.where((e) => e.id.notEqualValue("1"));
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` WHERE `$alias`.`id` != ?";
      expect(context.sqlsHistory, [sql]);
      expect(
        [
          ["1"]
        ],
        context.argsHistory,
      );
      expect(result, studentDatas.where((e) => e.id != "1").toList());
    },
  );

  test(
    "test select with where is null",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.where((e) => e.name.equalValue(null));
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` WHERE `$alias`.`name` IS NULL";
      expect(context.sqlsHistory, [sql]);
      expect(
        [[]],
        context.argsHistory,
      );
      expect(result, studentDatas.where((e) => e.name == null).toList());
    },
  );

  test(
    "test select with where is not null",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.where((e) => e.name.notEqualValue(null));
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` WHERE `$alias`.`name` IS NOT NULL";
      expect(context.sqlsHistory, [sql]);
      expect(
        [[]],
        context.argsHistory,
      );
      expect(result, studentDatas.where((e) => e.name != null).toList());
    },
  );

  test(
    "test select with where or",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.where((e) => e.id.equalValue("1").or(e.id.equalValue("2")));
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` WHERE `$alias`.`id` = ? OR `$alias`.`id` = ?";
      expect(context.sqlsHistory, [sql]);
      expect(
        [
          ["1", "2"]
        ],
        context.argsHistory,
      );
      expect(result, studentDatas.where((e) => e.id == "1" || e.id == "2").toList());
    },
  );

  test(
    "test select with where and",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.where((e) => e.name.notEqualValue(null).and(e.id.equalValue("3")));
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` WHERE `$alias`.`name` IS NOT NULL AND `$alias`.`id` = ?";
      expect(context.sqlsHistory, [sql]);
      expect(
        [
          ["3"]
        ],
        context.argsHistory,
      );
      expect(result, studentDatas.where((e) => e.name != null && e.id == "3").toList());
    },
  );

  test(
    "test select with order by",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.orderBy((e) => e.id);
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` ORDER BY `$alias`.`id` ASC";
      expect(context.sqlsHistory, [sql]);
      expect(
        [[]],
        context.argsHistory,
      );
      expect(result, [...studentDatas]..sort((a, b) => a.id.compareTo(b.id)));
    },
  );

  test(
    "test select with order by desc",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.orderBy((e) => e.id).descending();
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` ORDER BY `$alias`.`id` DESC";
      expect(context.sqlsHistory, [sql]);
      expect(
        [[]],
        context.argsHistory,
      );
      expect(result, [...studentDatas]..sort((a, b) => b.id.compareTo(a.id)));
    },
  );

  test(
    "test select with take and skip",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.skip(1).take(1);
      final result = await query.toList();
      String alias = context.prefixHistory.last;
      String sql = "SELECT ${studentModelColumns.map((e) => "`$alias`.`$e`").join(", ")} FROM `$studentModelTable` AS `$alias` LIMIT 1 OFFSET 1";
      expect(context.sqlsHistory, [sql]);
      expect(
        [[]],
        context.argsHistory,
      );
      expect(result, studentDatas.skip(1).take(1).toList());
    },
  );

  test(
    "test select with join",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.join(context.classModel, on: (t1, t2) => t1.classId.on(t2.id).select((t1, t2) => t1.select()));
      final result = await query.toList();
      String studentAlias = context.prefixHistory[0];
      String classAlias = context.prefixHistory[1];
      String joinAlias = context.prefixHistory[2];
      String sql = "SELECT ${studentModelColumns.map((e) => "`$joinAlias`.`${studentAlias}_$e`").join(", ")} FROM ("
          "SELECT ${studentModelColumns.map((e) => "`$studentAlias`.`$e` AS `${studentAlias}_$e`").join(", ")} FROM "
          "`$studentModelTable` "
          "AS `$studentAlias` INNER JOIN `$classModelTable` AS `$classAlias` ON `$studentAlias`.`class_id` = `$classAlias`.`id`) AS `$joinAlias`";
      expect(context.sqlsHistory, [sql]);
      expect(
        [[]],
        context.argsHistory,
      );
      final hasClassStudents = studentDatas.where((e) => classDatas.any((c) => c.id == e.classId)).toList();
      expect(result, hasClassStudents);
    },
  );
  test(
    "test select with join and where1",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.join(context.classModel, on: (t1, t2) => t1.classId.on(t2.id).select((t1, t2) => t1.select()));
      query = query.where((e) => e.id.equalValue("1"));
      final result = await query.toList();
      String studentAlias = context.prefixHistory[0];
      String classAlias = context.prefixHistory[1];
      String joinAlias = context.prefixHistory[2];
      String sql = "SELECT ${studentModelColumns.map((e) => "`$joinAlias`.`${studentAlias}_$e`").join(", ")} FROM ("
          "SELECT ${studentModelColumns.map((e) => "`$studentAlias`.`$e` AS `${studentAlias}_$e`").join(", ")} FROM "
          "`$studentModelTable` "
          "AS `$studentAlias` INNER JOIN `$classModelTable` AS `$classAlias` ON `$studentAlias`.`class_id` = `$classAlias`.`id`) AS `$joinAlias`"
          " WHERE `$joinAlias`.`${studentAlias}_id` = ?";
      expect(context.sqlsHistory, [sql]);
      expect(
        [
          ["1"]
        ],
        context.argsHistory,
      );
      final hasClassStudents = studentDatas.where((e) => classDatas.any((c) => c.id == e.classId)).toList();
      expect(result, hasClassStudents.where((e) => e.id == "1").toList());
    },
  );
  test(
    "test select with join and where2",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.where((e) => e.id.equalValue("1")).join(
            context.classModel.where((e) => e.id.equalValue("2")),
            on: (t1, t2) => t1.classId.on(t2.id).select(
                  (t1, t2) => t1.select(),
                ),
          );
      final result = await query.toList();
      String studentAlias = context.prefixHistory[0];
      String classAlias = context.prefixHistory[1];
      String joinAlias = context.prefixHistory[2];
      String sql = "SELECT ${studentModelColumns.map((e) => "`$joinAlias`.`${studentAlias}_$e`").join(", ")} FROM ("
          "SELECT ${studentModelColumns.map((e) => "`$studentAlias`.`$e` AS `${studentAlias}_$e`").join(", ")} FROM "
          "`$studentModelTable` "
          "AS `$studentAlias` INNER JOIN `$classModelTable` AS `$classAlias` ON `$studentAlias`.`class_id` = `$classAlias`.`id`"
          " WHERE `$studentAlias`.`id` = ? AND `$classAlias`.`id` = ?) AS `$joinAlias`";
      expect(context.sqlsHistory, [sql]);
      expect(
        [
          ["1", "2"]
        ],
        context.argsHistory,
      );
      final hasClassStudents = studentDatas.where((e) => classDatas.any((c) => c.id == e.classId)).toList();
      expect(result, hasClassStudents.where((e) => e.id == "1" && e.classId == "2").toList());
    },
  );

  test(
    "test select with join and select1",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel.join(
        context.classModel,
        on: (t1, t2) => t1.classId.on(t2.id).select(
              (t1, t2) => (student: t1.select(), cls: t2.select()),
            ),
      );
      final result = await query.toList();
      String studentAlias = context.prefixHistory[0];
      String classAlias = context.prefixHistory[1];
      String joinAlias = context.prefixHistory[2];
      String sql = "SELECT ${studentModelColumns.map((e) => "`$joinAlias`.`${studentAlias}_$e`").join(", ")}"
          ", ${classModelColumns.map((e) => "`$joinAlias`.`${classAlias}_$e`").join(", ")} "
          "FROM ("
          "SELECT "
          "${studentModelColumns.map((e) => "`$studentAlias`.`$e` AS `${studentAlias}_$e`").join(", ")}"
          ", ${classModelColumns.map((e) => "`$classAlias`.`$e` AS `${classAlias}_$e`").join(", ")} "
          "FROM "
          "`$studentModelTable` "
          "AS `$studentAlias` INNER JOIN `$classModelTable` AS `$classAlias` ON `$studentAlias`.`class_id` = `$classAlias`.`id`) AS `$joinAlias`";
      expect(context.sqlsHistory, [sql]);
      expect(
        [[]],
        context.argsHistory,
      );

      final hasClassStudents = studentDatas.where((e) => classDatas.any((c) => c.id == e.classId)).toList();
      expect(
        result,
        hasClassStudents.map((e) => (student: e, cls: classDatas.firstWhere((c) => c.id == e.classId))).toList(),
      );
    },
  );

  test(
    "test select with join and select2",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel
          .join(
            context.classModel,
            on: (t1, t2) => t1.classId.on(t2.id).select(
                  (t1, t2) => t1.selectAll(),
                ),
          )
          .select((t) => t.id);
      final result = await query.toList();
      String studentAlias = context.prefixHistory[0];
      String classAlias = context.prefixHistory[1];
      String joinAlias = context.prefixHistory[3];
      String sql = "SELECT `$joinAlias`.`${studentAlias}_id`"
          " FROM ("
          "SELECT "
          "${studentModelColumns.map((e) => "`$studentAlias`.`$e` AS `${studentAlias}_$e`").join(", ")}"
          " FROM "
          "`$studentModelTable` "
          "AS `$studentAlias` INNER JOIN `$classModelTable` AS `$classAlias` ON `$studentAlias`.`class_id` = `$classAlias`.`id`) AS `$joinAlias`";
      expect(
        context.sqlsHistory,
        [sql],
      );
      expect(
        [[]],
        context.argsHistory,
      );

      final hasClassStudents = studentDatas.where((e) => classDatas.any((c) => c.id == e.classId)).toList();
      expect(
        result,
        hasClassStudents.map((e) => e.id).toList(),
      );
    },
  );

  test(
    "test reverse",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel
          .join(
            context.classModel,
            on: (t1, t2) => t1.classId.on(t2.id).select(
                  (t1, t2) => t1.id,
                ),
          )
          .select((t) => t.reverse<StudentModel>().id)
          .where((t) => t.reverse<StudentModel>().id.equalValue('1'));
      final result = await query.toList();
      String studentAlias = context.prefixHistory[0];
      String classAlias = context.prefixHistory[1];
      String joinAlias = context.prefixHistory[3];
      String sql = "SELECT `$joinAlias`.`${studentAlias}_id`"
          " FROM ("
          "SELECT "
          "`$studentAlias`.`id` AS `${studentAlias}_id`"
          " FROM "
          "`$studentModelTable` "
          "AS `$studentAlias` INNER JOIN `$classModelTable` AS `$classAlias` ON `$studentAlias`.`class_id` = `$classAlias`.`id`) AS `$joinAlias`"
          " WHERE `$joinAlias`.`${studentAlias}_id` = ?";
      expect(
        context.sqlsHistory,
        [sql],
      );
      expect(
        [
          ["1"]
        ],
        context.argsHistory,
      );

      final hasClassStudents = studentDatas.where((e) => classDatas.any((c) => c.id == e.classId)).toList();
      expect(
        result,
        hasClassStudents.where((e) => e.id == '1').map((e) => e.id).toList(),
      );
    },
  );
  test(
    "test reverse2",
    () async {
      final TestContext context = TestContext();
      var query = context.studentModel
          .join(
            context.classModel,
            on: (t1, t2) => t1.classId.on(t2.id).select(
                  (t1, t2) => (studentModel: t1.selectAll(), classModel: t2.selectAll()),
                ),
          )
          .where((t) => t.reverse<StudentModel>().id.equalValue('1').and(t.reverse<ClassModel>().id.equalValue('2')));
      final result = await query.toList();
      String studentAlias = context.prefixHistory[0];
      String classAlias = context.prefixHistory[1];
      String joinAlias = context.prefixHistory[2];
      String sql = "SELECT "
          "${studentModelColumns.map((e) => "`$joinAlias`.`${studentAlias}_$e`").join(", ")}"
          ", ${classModelColumns.map((e) => "`$joinAlias`.`${classAlias}_$e`").join(", ")}"
          " FROM ("
          "SELECT "
          "${studentModelColumns.map((e) => "`$studentAlias`.`$e` AS `${studentAlias}_$e`").join(", ")}"
          ", ${classModelColumns.map((e) => "`$classAlias`.`$e` AS `${classAlias}_$e`").join(", ")}"
          " FROM "
          "`$studentModelTable` "
          "AS `$studentAlias` INNER JOIN `$classModelTable` AS `$classAlias` ON `$studentAlias`.`class_id` = `$classAlias`.`id`) AS `$joinAlias`"
          " WHERE `$joinAlias`.`${studentAlias}_id` = ? AND `$joinAlias`.`${classAlias}_id` = ?";
      expect(
        context.sqlsHistory,
        [sql],
      );
      expect(
        [
          ["1", "2"]
        ],
        context.argsHistory,
      );

      final hasClassStudents = studentDatas
          .map(
            (e) => (studentModel: e, classModel: classDatas.firstWhereOrNull((c) => c.id == e.classId)),
          )
          .where(
            (e) => e.classModel != null && e.studentModel.id == '1' && e.classModel!.id == '2',
          )
          .toList();
      expect(
        result,
        hasClassStudents,
      );
    },
  );
  test(
    "test remove",
    () async {
      final TestContext context = TestContext();
      var query = await context.studentModel.where((e) => e.id.equalValue("4")).firstOrNull();
      expect(query, studentDatas.where((e) => e.id == "4").first);
      query!.remove();
      await context.saveChanges();
      var result = await context.studentModel.where((e) => e.id.equalValue("4")).firstOrNull();
      expect(result, null);
    },
  );
}
