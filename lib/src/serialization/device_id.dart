import 'common.dart';

String deserializeDeviceId(Map<Object?, Object?> response) {
  Map<String, dynamic> data = response.cast<String, dynamic>();
  String? deviceId = data[keyValue];
  if (data[keyType] != _typeDeviceId || deviceId == null) {
    throw Exception("Invalid availability response: ${response}");
  }
  return deviceId;
}

const _typeDeviceId = "deviceID";
