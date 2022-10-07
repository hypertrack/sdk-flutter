import 'package:hypertrack_plugin/data_types/json.dart';

Map<String, dynamic> serializeGeotag(JSONObject data) {
  return { _keyData: data.serialize() };
}

const _keyData = "data";
