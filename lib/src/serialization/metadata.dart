import 'package:hypertrack_plugin/data_types/json.dart';

Map<String, dynamic> serializeMetadata(JSONObject data) {
  return data.serialize();
}
