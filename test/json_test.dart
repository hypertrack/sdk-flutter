import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:test/test.dart';

void main() {
  test('Serialize-deserialize JSON', () {
    JSONObject testValue = JSONObject({
      "string": JSONString("value"),
      "number": JSONNumber(1),
      "bool": JSONBool(false),
      "object": JSONObject({
        "data": JSONBool(true)
      }),
      "intArray": JSONArray([JSONNumber(1), JSONNumber(2)]),
      "objectArray": JSONArray([
        JSONObject({
          "index": JSONNumber(0)
        }),
        JSONObject({
          "index": JSONNumber(1)
        })
      ])
    });

    print(testValue.serialize().toString());
    Map<String, dynamic> expected = {
      "string": "value",
      "number": 1,
      "bool": false,
      "object": {
        "data": true
      },
      "intArray": [1,2],
      "objectArray": [
        {
          "index": 0
        },
        {
          "index": 1
        }
      ]
    };

    expect(expected, testValue.serialize());
  });
}
