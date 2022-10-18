import 'package:hypertrack_plugin/src/serialization/common.dart';

bool deserializeIsTracking(Map<Object?, Object?> response) {
  Map<String, dynamic> data = response.cast<String, dynamic>();
  bool? isTracking = data[keyValue];
  if(data[keyType] != _typeIsTracking || isTracking == null) {
    throw Exception("Invalid isTracking response: ${response}");
  }
  return isTracking;
}

const _typeIsTracking = "isTracking";
