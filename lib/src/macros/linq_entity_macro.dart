// import 'dart:async';
// import 'dart:developer';

// import 'package:collection/collection.dart';
// import 'package:macros/macros.dart';

// final _dartCore = Uri.parse('dart:core');
// final _selfLibrary = Uri.parse('package:linq/example/test_macros.dart');

// macro class LinqEntityObj implements ClassDeclarationsMacro, ClassDefinitionMacro {
//   const LinqEntityObj({
//     required this.object,
//     required this.tableName,
//     this.convertCamelToUnderscore = false,
//   });
//   final String object;
//   final String tableName;
//   final bool convertCamelToUnderscore;
//   @override
//   FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
//     final override = await builder.resolveIdentifier(Uri.parse('package:meta/meta.dart'), 'override');
//     final string = NamedTypeAnnotationCode(name: await builder.resolveIdentifier(_dartCore, 'String'));
//     final list = await builder.resolveIdentifier(_dartCore, 'List');
//     final object = await builder.resolveIdentifier(clazz.library.uri, this.object);
//     final queryModelFieldDescriptor = await builder.resolveIdentifier(Uri.parse('package:linq/src/query_descriptor.dart'), 'QueryModelFieldDescriptor');
//     builder.declareInType(
//       DeclarationCode.fromParts(
//         ["@", override, "\n", object, " create();"],
//       ),
//     );
//     builder.declareInType(
//       DeclarationCode.fromParts(
//         [
//           "@",
//           override,
//           "\n",
//           string,
//           " tableName();",
//         ],
//       ),
//     );

//     builder.declareInType(
//       DeclarationCode.fromParts(
//         [
//           "@",
//           override,
//           "\n",
//           NamedTypeAnnotationCode(name: list, typeArguments: [NamedTypeAnnotationCode(name: queryModelFieldDescriptor)]),
//           " fields();",
//         ],
//       ),
//     );
//   }

//   @override
//   FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
//     final methods = await builder.methodsOf(clazz);
//     final create = methods.firstWhereOrNull((c) => c.identifier.name == 'create');
//     final tableName = methods.firstWhereOrNull((c) => c.identifier.name == 'tableName');
//     final fields = methods.firstWhereOrNull((c) => c.identifier.name == 'fields');
//     await (
//       _definitionCreate(clazz, builder, create),
//       _definitionTableName(clazz, builder, tableName),
//       _definitionFields(clazz, builder, fields),
//     ).wait;
//   }

//   Future _definitionCreate(ClassDeclaration clazz, TypeDefinitionBuilder builder, MethodDeclaration? declaration) async {
//     if (declaration == null) return;
//     final object = await builder.resolveIdentifier(clazz.library.uri, this.object);
//     final methodBuilder = await builder.buildMethod(declaration.identifier);
//     methodBuilder.augment(
//       FunctionBodyCode.fromParts([
//         "=> ",
//         object,
//         "();",
//       ]),
//     );
//   }

//   Future _definitionTableName(ClassDeclaration clazz, TypeDefinitionBuilder builder, MethodDeclaration? declaration) async {
//     if (declaration == null) return;
//     final methodBuilder = await builder.buildMethod(declaration.identifier);
//     methodBuilder.augment(
//       FunctionBodyCode.fromString(
//         "=> '$tableName';",
//       ),
//     );
//   }

//   Future _definitionFields(ClassDeclaration clazz, TypeDefinitionBuilder builder, MethodDeclaration? declaration) async {
//     if (declaration == null) return;
    
//     final object = await builder.resolveIdentifier(clazz.library.uri, this.object);
//     final queryModelFieldDescriptor = await builder.resolveIdentifier(Uri.parse('package:linq/src/query_descriptor.dart'), 'QueryModelFieldDescriptor');
//     final declarations = await builder.topLevelDeclarationsOf(clazz.library);
//     final objectDeclaration = declarations.firstWhereOrNull((c) => c is ClassDeclaration && c.identifier.name == this.object);
//     if (objectDeclaration == null) return;
//     final fields = await builder.fieldsOf(objectDeclaration as TypeDeclaration);
//     // final fields = builder.fieldsOf(objectType as TypeDeclaration);
//     // if (objectType == null) return;
//     // print(objectType.runtimeType);

//     final methodBuilder = await builder.buildMethod(declaration.identifier);

//     final linqColumObjIdentifier = await builder.resolveIdentifier(Uri.parse('package:linq/src/gen/linq.dart'), 'LinqColum');
//     final linqColumObj = await builder.declarationOf(linqColumObjIdentifier) as TypeDeclaration;
//     final linqColumObjConstructor = (await builder.constructorsOf(linqColumObj)).first;

//     final defaultValueMethodIdentifier = await builder.resolveIdentifier(Uri.parse('package:linq/src/query_descriptor.dart'), 'defaultValue');
//     final defaultValueMethod = await builder.declarationOf(defaultValueMethodIdentifier) as FunctionDeclaration;

//     final myString = await builder.resolveIdentifier(clazz.library.uri, 'String');
    
//     methodBuilder.augment(
//       FunctionBodyCode.fromParts(
//         [
//           "=> [\n\t\t",
//           ...(await (fields.map<Future>(
//             (e) async {
//               var fieldType = e.type;
//               if (fieldType is! NamedTypeAnnotation) {
//                 return <Object>[];
//               }
//               Object name = e.identifier.name;
//               final fieldTypeDecl = await builder.declarationOf(fieldType.identifier);
//               Object dbName = name;
//               if (convertCamelToUnderscore) {
//                 final buffer = StringBuffer();
//                 for (var i = 0; i < e.identifier.name.length; i++) {
//                   final current = e.identifier.name[i];
//                   if (current.toUpperCase() == current) {
//                     buffer.write("_");
//                   }
//                   buffer.write(current.toLowerCase());
//                 }
//                 dbName = buffer.toString();
//               }
//               for (var element in e.metadata) {
//                 if (element is ConstructorMetadataAnnotation) {
//                   final filedAnnotationType = await builder.declarationOf(element.constructor);
//                   if (filedAnnotationType.identifier == linqColumObjConstructor.identifier) {
//                     final ConstructorMetadataAnnotation e = element;
//                     Object? isPrimaryKey;
//                     Object? codec;
//                     for (var element in e.namedArguments.entries) {
//                       Object code = element.value.parts.first;
//                       try {
//                         var text = element.value.parts.first.toString();
//                         if (element.key == "codec") {
//                           text = text.substring(0, text.indexOf("("));
//                         }
//                         code = await builder.resolveIdentifier(clazz.library.uri, text);
//                       } catch (_) {}
                      
//                       if (element.key == "colum") {
//                         dbName = code;
//                       }
//                       if (element.key == "primaryKey") {
//                         isPrimaryKey = code;
//                       }
//                       if (element.key == "codec") {
//                         codec = code;
//                       }
//                     }
//                     return <Object>[
//                       NamedTypeAnnotationCode(
//                         name: queryModelFieldDescriptor,
//                         typeArguments: [
//                           NamedTypeAnnotationCode(name: object),
//                           NamedTypeAnnotationCode(name: fieldTypeDecl.identifier),
//                         ],
//                       ),
//                       "(\n",
//                       "name: \"",
//                       name,
//                       "\",\n",
//                       "dbName: ",
//                       dbName,
//                       ",\n",
//                       if(isPrimaryKey != null) ...["isPrimaryKey:",
//                       isPrimaryKey,",\n"],
//                       "defaultValue: ",
//                       if(codec==null) ...[
//                         defaultValueMethod.identifier,
//                         "<",
//                         fieldType.identifier,
//                         ">(),\n",
//                       ],
//                      if(codec!=null)... [codec,"().defaultValue,\n","codec:",codec,"(),\n"],
//                      "get: (model) => model.$name,\n",
//                       "set: (model, value) => model.$name = value,\n",
//                       "),\n",
//                     ];
//                     // return <Object>[
//                     //   "\t\t",
//                     // NamedTypeAnnotationCode(
//                     //   name: queryModelFieldDescriptor,
//                     //   typeArguments: [
//                     //     NamedTypeAnnotationCode(name: object),
//                     //     NamedTypeAnnotationCode(name: fieldTypeDecl.identifier),
//                     //   ],
//                     // ),
//                     //   "(",
//                     //   ...e.positionalArguments,

//                     //   ...(await (e.namedArguments.entries.map<Future<List<Object>>>((e) async {
                        
//                     //     return [
//                     //       e.key,
//                     //       ":",
//                     //       ...(
//                     //         await (e.value.parts.map<Future<List<Object>>>((f) async {
//                     //         try {
//                     //           var text = f.toString();
//                     //           if (e.key == "codec") {
//                     //             text = text.substring(0, text.indexOf("("));
//                     //           }
//                     //           final type = await builder.resolveIdentifier(clazz.library.uri, text);
//                     //           return [type];
//                     //         } catch (_) {}
//                     //         return [f];
//                     //       })).wait
//                     //       ).expand((e)=>e),
//                     //       // ...(await e.value.parts.map<Future<List<Object>>>((f) async => [ await builder.resolveIdentifier(clazz.library.uri, 'String')]).wait).expand((g) => g),
//                     //       // e.value.kind.toString(),
//                     //       ","
//                     //     ];
//                     //   })).wait).expand((e) => e),
//                     //   "),\n",
//                     //   // "_linqModelFieldDescriptorFor$name()",
//                     // ];
//                   }
//                 }
//               }
//               // return <Object>["qqlol"];
//               return <Object>[
//                 NamedTypeAnnotationCode(
//                   name: queryModelFieldDescriptor,
//                   typeArguments: [
//                     NamedTypeAnnotationCode(name: object),
//                     NamedTypeAnnotationCode(name: fieldTypeDecl.identifier),
//                   ],
//                 ),
//                 "(",
//                 "name: \"$name\",",
//                 "dbName: \"$dbName\",",
//                 "defaultValue: ",
//                 defaultValueMethod.identifier,
//                 "<",
//                 fieldType.identifier,
//                 ">()",
//                 "),\n",
//               ];
//             },
//           ).wait))
//               .expand((e) => e),
//           "\t];",
//         ],
//       ),
//     );
//   }
// }
