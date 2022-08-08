import 'common.dart';

Map<String, dynamic> serializeDeviceName(String name) {
  return {
    keyType: _typeDeviceName,
    keyValue: name
  };
}

const _typeDeviceName = "deviceName";
