import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:test/test.dart';

void main() {
  test('Serialize JSON', () {
    JSONObject testValue = JSONObject({
      "null": JSONNull(),
      "string": JSONString("value"),
      "number": JSONNumber(1),
      "bool": JSONBool(false),
      "object": JSONObject({"data": JSONBool(true), "value": JSONNull()}),
      "nullArray": JSONArray([JSONNull(), JSONNull()]),
      "intArray": JSONArray([JSONNumber(1), JSONNumber(2), JSONNull()]),
      "objectArray": JSONArray([
        JSONObject({"index": JSONNumber(0)}),
        JSONObject({"index": JSONNumber(1)})
      ])
    });

    print(testValue.serialize().toString());
    Map<String, dynamic> expected = {
      "null": null,
      "string": "value",
      "number": 1,
      "bool": false,
      "object": {"data": true, "value": null},
      "nullArray": [null, null],
      "intArray": [1, 2, null],
      "objectArray": [
        {"index": 0},
        {"index": 1},
      ]
    };

    expect(expected, testValue.serialize());
  });
}
