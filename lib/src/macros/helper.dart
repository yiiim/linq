// import 'package:macros/macros.dart';

// List<Object> fieldDescriptorCode({
//   required Identifier queryModelFieldDescriptorIdentity,
//   required ClassDeclaration clazz,
//   required FieldDeclaration field,
//   required Identifier defaultValueMethodIdentifier,
//   ConstructorMetadataAnnotation? fieldColumnAnnotation,
// }) {
//   final String name = field.identifier.name;
//   var dbName = name;
//   if (fieldColumnAnnotation != null) {
//     final dbNameAnnotation = fieldColumnAnnotation.arguments.firstWhereOrNull((element) => element.name == "dbName");
//     if (dbNameAnnotation != null) {
//       dbName = dbNameAnnotation.value;
//     }
//   }

//   return <Object>[
//     NamedTypeAnnotationCode(
//       name: queryModelFieldDescriptorIdentity,
//       typeArguments: [
//         NamedTypeAnnotationCode(name: clazz.identifier),
//         NamedTypeAnnotationCode(name: field.identifier),
//       ],
//     ),
//     "(",
//     "name: \"$name\",",
//     "dbName: \"$dbName\",",
//     "defaultValue: ",
//     defaultValueMethodIdentifier,
//     "<",
//     (field.type as NamedTypeAnnotation).identifier,
//     ">()",
//     ")\n",
//   ];
// }
