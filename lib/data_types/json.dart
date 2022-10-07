abstract class _JSONValue<T> {
  T serialize();

  @override
  String toString() {
    return serialize().toString();
  }
}

class JSONObject extends _JSONValue<Map<String, dynamic>> {
  Map<String, _JSONValue?> fields;

  JSONObject(this.fields);

  @override
  Map<String, dynamic> serialize() {
    return fields.map((key, value) {
      return MapEntry(key, value?.serialize());
    });
  }
}

class JSONArray<T, K extends _JSONValue<T>, I extends Iterable<T>> extends _JSONValue<I> {
  Iterable<K> items;

  JSONArray(this.items);

  @override
  I serialize() {
    return items.map((e) => e.serialize()) as I;
  }
}

class JSONString extends _JSONValue {
  String value;

  JSONString(this.value);

  @override
  String serialize() {
    return value;
  }
}

class JSONNumber extends _JSONValue {
  double value;

  JSONNumber(this.value);

  @override
  double serialize() {
    return value;
  }
}

class JSONBool extends _JSONValue {
  bool value;

  JSONBool(this.value);

  @override
  bool serialize() {
    return value;
  }
}
