// import 'dart:async';

// import 'package:collection/collection.dart';
// import 'package:macros/macros.dart';

// import 'linq_entity.dart';
// import 'package:linq/linq.dart';

// macro class LinqColumObj implements FieldDeclarationsMacro, FieldDefinitionMacro {
//   const LinqColumObj({
//     this.colum,
//     this.primaryKey = false,
//     this.dbType,
//     this.codec,
//     this.ignore = false,
//   });

//   final String? colum;
//   final bool primaryKey;
//   final Type? dbType;
//   final DataFieldCodec? codec;
//   final bool ignore;
  
//   @override
//   FutureOr<void> buildDeclarationsForField(FieldDeclaration field, MemberDeclarationBuilder builder) async {
    
//     // final queryModelFieldDescriptor = await builder.resolveIdentifier(Uri.parse('package:linq/src/query_descriptor.dart'), 'QueryModelFieldDescriptor');
//     // final name = colum ?? field.identifier.name;
//     // var dbName = name;
//     // final buffer = StringBuffer();
//     //   for (var i = 0; i < name.length; i++) {
//     //     final current = name[i];
//     //     if (current.toUpperCase() == current) {
//     //       buffer.write("_");
//     //     }
//     //     buffer.write(current.toLowerCase());
//     //   }
//     //   dbName = buffer.toString();
//     // builder.declareInLibrary(DeclarationCode.fromParts([
//     //   NamedTypeAnnotationCode(
//     //     name: queryModelFieldDescriptor,
//     //     typeArguments: [
//     //       NamedTypeAnnotationCode(name: field.definingType),
//     //       NamedTypeAnnotationCode(name: (field.type as NamedTypeAnnotation).identifier),
//     //     ],
//     //   ),
//     //   " _linqModelFieldDescriptorFor${field.identifier.name}(){\n",
//     //   "\treturn ",
//     //   NamedTypeAnnotationCode(
//     //     name: queryModelFieldDescriptor,
//     //     typeArguments: [
//     //       NamedTypeAnnotationCode(name: field.definingType),
//     //       NamedTypeAnnotationCode(name: (field.type as NamedTypeAnnotation).identifier),
//     //     ],
//     //   ),
//     //   "(",
//     //   "name: '$name',",
//     //   "dbName: '$dbName',",
//     //   ...(field.metadata.first as ConstructorMetadataAnnotation).namedArguments.entries.map<List<Object>>((e) => [e.key,":",e.value]).expand((e)=>e),
//     //   "defaultValue: " ,
//     //   ");",
//     //   "\n}",
//     // ],),);
//   }
  
//   @override
//   FutureOr<void> buildDefinitionForField(FieldDeclaration field, VariableDefinitionBuilder builder) async {
    
//     // final type = await builder.declarationOf(field.definingType) as ClassDeclaration;
//     // final methods = await builder.methodsOf(type);
//     // final fieldDescriptorMethod = methods.firstWhereOrNull((c) => c.identifier.name == "_linqModelFieldDescriptorFor${field.identifier.name}");
//     // if (fieldDescriptorMethod == null) return;
//   }
// }

// macro class LinqObj with _DeclarationLinqObj, _DefinitionLinqObj, DeclarationLinqEntity implements ClassDeclarationsMacro, ClassDefinitionMacro, ClassTypesMacro {
//   const LinqObj({this.tableName});

//   @override
//   FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
//     await typeLinqEntity(clazz, builder);
//   }

//   @override
//   FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) {
//     // builder.declareInLibrary(
//     //   DeclarationCode.fromParts(
//     //     [
//     //       'import \'package:linq/linq.dart\';',
//     //     ],
//     //   ),  
//     // );
//     // _declareUpdate(clazz, builder);
//     // _declareRemove(clazz, builder);
//     // builder.declareInLibrary(
//     //   DeclarationCode.fromParts(
//     //     [
//     //       'extension LinqJoinOnPseudoClassTeamDataModelExtension<T> on LinqJoinOnPseudoClass<TeamDataModel, T> {}',
//     //     ],
//     //   ),
//     // );
//   }

//   @override
//   FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
//     final methods = await builder.methodsOf(clazz);
//     final update = methods.firstWhereOrNull((c) => c.identifier.name == 'update');
//     final remove = methods.firstWhereOrNull((c) => c.identifier.name == 'remove');
//     // await (
//     //   _definitionUpdate(clazz, builder, update),
//     //   _definitionRemove(clazz, builder, remove),
//     // ).wait;
//   }
  

//   @override
//   final String? tableName;
// }

// mixin _DeclarationLinqEntity {}

// mixin _DefinitionLinqObj {
//   Future _definitionUpdate(ClassDeclaration clazz, TypeDefinitionBuilder builder, MethodDeclaration? declaration) async {
//     if (declaration == null) return;
//     final methodBuilder = await builder.buildMethod(declaration.identifier);
//     methodBuilder.augment(
//       FunctionBodyCode.fromParts(
//         [
//           "{"
//               "(linqObject as LinqObject<${clazz.identifier.name}>).update(block);"
//               "}"
//         ],
//       ),
//     );
//   }

//   Future _definitionRemove(ClassDeclaration clazz, TypeDefinitionBuilder builder, MethodDeclaration? declaration) async {
//     if (declaration == null) return;
//     final methodBuilder = await builder.buildMethod(declaration.identifier);
//     methodBuilder.augment(
//       FunctionBodyCode.fromString(
//         "=> linqObject.remove();",
//       ),
//     );
//   }
// }

// mixin _DeclarationLinqObj {
//   void _declareUpdate(ClassDeclaration clazz, MemberDeclarationBuilder builder) {
//     builder.declareInType(
//       DeclarationCode.fromParts(
//         [
//           '  void',
//           ' update(void Function(LinqPseudoClass<${clazz.identifier.name}, ${clazz.identifier.name}> e) block);',
//         ],
//       ),
//     );
//   }

//   void _declareRemove(ClassDeclaration clazz, MemberDeclarationBuilder builder) {
//     builder.declareInType(
//       DeclarationCode.fromParts(
//         [
//           '  void',
//           ' remove();',
//         ],
//       ),
//     );
//   }
// }

// mixin _DeclareLinqObj {
//   void _declareUpdate(ClassDeclaration clazz, MemberDeclarationBuilder builder) {
//     builder.declareInType(
//       DeclarationCode.fromParts(
//         [
//           '  external ',
//           'void',
//           ' update(void Function(LinqPseudoClass<${clazz.identifier.name}, ${clazz.identifier.name}> e) block);',
//         ],
//       ),
//     );
//   }

//   void _declareRemove(ClassDeclaration clazz, MemberDeclarationBuilder builder) {
//     builder.declareInType(
//       DeclarationCode.fromParts(
//         [
//           '  external ',
//           'void',
//           ' remove();',
//         ],
//       ),
//     );
//   }
// }
