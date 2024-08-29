// ignore_for_file: unnecessary_no_such_method

import 'dart:convert';

abstract class JSON<T> {
  static JSONObject? fromMap(Map<String, dynamic> map) {
    try {
      return fromMap(map);
    } catch (Exception) {
      return null;
    }
  }

  static JSONObject? fromString(String jsonString) {
    try {
      return JSON.fromMap(json.decode(jsonString));
    } catch (Exception) {
      return null;
    }
  }

  T serialize();

  /// @nodoc
  @override
  String toString() {
    return serialize().toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class JSONObject extends JSON<Map<String, dynamic>> {
  Map<String, JSON<dynamic>?> fields;

  JSONObject(this.fields);

  @override
  Map<String, dynamic> serialize() {
    return fields.map((key, value) {
      return MapEntry(key, value?.serialize());
    });
  }

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class JSONArray<T, K extends JSON<T>, I extends Iterable<T>> extends JSON<I> {
  Iterable<K> items;

  JSONArray(this.items);

  @override
  I serialize() {
    return items.map((e) => e.serialize()).toList() as I;
  }

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class JSONString extends JSON<dynamic> {
  String value;

  JSONString(this.value);

  @override
  String serialize() {
    return value;
  }

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class JSONNumber extends JSON<dynamic> {
  double value;

  JSONNumber(this.value);

  @override
  double serialize() {
    return value;
  }

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class JSONBool extends JSON<dynamic> {
  bool value;

  JSONBool(this.value);

  @override
  bool serialize() {
    return value;
  }

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class JSONNull extends JSON<dynamic> {
  JSONNull();

  @override
  dynamic serialize() {
    return null;
  }

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

JSONObject fromMap(Map<Object?, Object?> map) {
  return JSONObject(map.map((rawKey, value) {
    String key = rawKey as String;
    if (value is Map<Object?, Object?>) {
      return MapEntry(key, fromMap(value));
    } else if (value is List<Object?>) {
      return MapEntry(key, _fromList(value));
    } else if (value is String) {
      return MapEntry(key, JSONString(value));
    } else if (value is double) {
      return MapEntry(key, JSONNumber(value));
    } else if (value is bool) {
      return MapEntry(key, JSONBool(value));
    } else if (value == null) {
      return MapEntry(key, JSONNull());
    } else {
      throw Exception("Unexpected type ${value.runtimeType} in JSON map");
    }
  }));
}

// ignore: strict_raw_type
JSONArray _fromList(List<Object?> list) {
  return JSONArray(list.map((e) {
    if (e is Map<Object?, Object?>) {
      return fromMap(e);
    } else if (e is List<Object?>) {
      return _fromList(e) as JSON<dynamic>;
    } else if (e is String) {
      return JSONString(e);
    } else if (e is double) {
      return JSONNumber(e);
    } else if (e is bool) {
      return JSONBool(e);
    } else if (e == null) {
      return JSONNull();
    } else {
      throw Exception("Unexpected type ${e.runtimeType} in JSON list");
    }
  }).toList());
}
