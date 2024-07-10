import 'dart:convert';

class Linq<T> {
  const Linq({
    this.tableName,
    this.convertCamelToUnderscore = true,
  });
  final String? tableName;
  final bool convertCamelToUnderscore;
}

class LinqMember {
  const LinqMember();
}

abstract class DataFieldCodec<S, T> extends Codec<S, T> {
  const DataFieldCodec();

  S get defaultValue;
}

class LinqColum {
  const LinqColum({
    this.colum,
    this.primaryKey = false,
    this.ignore = false,
    this.dbType,
    this.codec,
  }) : assert(dbType == null || codec != null, 'codec must be provided when dbType is provided');
  final String? colum;
  final bool primaryKey;
  final Type? dbType;
  final DataFieldCodec? codec;
  final bool ignore;
}

class LinqContextObject {
  const LinqContextObject(this.entitys);
  final List<Type> entitys;
}
