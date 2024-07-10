// import 'package:collection/collection.dart';
// import 'package:macros/macros.dart';

// final _dartCore = Uri.parse('dart:core');
// final _thisLibrary = Uri.parse('package:linq/linq.dart');

// class _Colum {
//   const _Colum({
//     required this.name,
//     // required this.field,
//     // required this.dbType,
//     this.codecFactory,
//     this.isPrimaryKey = false,
//   });
//   final String name;
//   // final FieldElement field;
//   // final DartType dbType;
//   final String? codecFactory;
//   final bool isPrimaryKey;
// }

// mixin DeclarationLinqEntity {
//   String? get tableName;
//   Future typeLinqEntity(ClassDeclaration clazz, ClassTypeBuilder builder) async {
//     final linqEntity = await builder.resolveIdentifier(Uri.parse('package:linq/src/entity.dart'), 'LinqEntity');
//     final string = NamedTypeAnnotationCode(name: await builder.resolveIdentifier(_dartCore, 'String'));
//     final list = await builder.resolveIdentifier(_dartCore, 'List');
//     final queryModelFieldDescriptor = await builder.resolveIdentifier(Uri.parse('package:linq/src/query_descriptor.dart'), 'QueryModelFieldDescriptor');
//     // ignore: deprecated_member_use
//     final override = await builder.resolveIdentifier(Uri.parse('package:meta/meta.dart'), 'override');
//     final clsName = clazz.identifier.name;
//     final linqEntityObj = await builder.resolveIdentifier(Uri.parse('package:linq/src/macros/linq_entity_macro.dart'), 'LinqEntityObj');

//     String tableName = this.tableName ?? clsName;

//     builder.declareType(
//       "${clsName}Entity",
//       DeclarationCode.fromParts(
//         [
//           "@",
//           linqEntityObj,
//           "(object: '$clsName', tableName: '$tableName')",
//           "\n",
//           "class ${clsName}Entity extends ",
//           NamedTypeAnnotationCode(name: linqEntity, typeArguments: [NamedTypeAnnotationCode(name: clazz.identifier)]),
//           "{",
//           // "\n",
//           // "@",
//           // override,
//           // "\n",
//           // clazz.identifier,
//           // " create() => ",
//           // clazz.identifier,
//           // "();\n ",
//           // "@",
//           // override,
//           // "\n",
//           // string,
//           // " tableName() => '$tableName';\n",
//           // "@",
//           // override,
//           // "\n",
//           // NamedTypeAnnotationCode(name: list, typeArguments: [NamedTypeAnnotationCode(name: queryModelFieldDescriptor)]),
//           // " fields() => ",
//           "}",
//         ],
//       ),
//     );
//   }

//   Future definitionLinqEntity(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
//     final types = await builder.typesOf(clazz.library);
//     final entity = types.firstWhereOrNull((c) => c.identifier.name == "${clazz.identifier.name}Entity");

//     if (entity != null) {
//       builder.declareInType(
//         DeclarationCode.fromParts(
//           [
//             'class ${clazz.identifier.name}Entity extends LinqEntity<${clazz.identifier.name}> {}',
//           ],
//         ),
//       );
//     }
//     final clsName = clazz.identifier.name;
//     builder.declareInLibrary(
//       DeclarationCode.fromParts(
//         [
//           'external class Entitydd {}',
//         ],
//       ),
//     );
//   }

//   Future declareLinqEntity(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
//     final types = await builder.typesOf(clazz.library);
//     final entity = types.firstWhereOrNull((c) => c.identifier.name == "${clazz.identifier.name}Entity");
//     final clsName = clazz.identifier.name;
//     final fields = builder.fieldsOf(clazz);
//     // builder.
//   }
// }
