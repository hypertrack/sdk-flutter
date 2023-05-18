import '../../data_types/location.dart';
import 'common.dart';

Map<String, dynamic> serializeLocation(Location location) {
  return {
    keyType: _typeLocation,
    keyValue: {keyLatitude: location.latitude, keyLongitude: location.longitude}
  };
}

Location deserializeLocation(Map<Object?, Object?> map) {
  try {
    final data =
        (map[keyValue] as Map<Object?, Object?>).cast<String, double>();
    return Location(data[keyLatitude]!, data[keyLongitude]!);
  } catch (e) {
    throw Exception("Invalid location $map $e");
  }
}

const keyLatitude = "latitude";
const keyLongitude = "longitude";
const _typeLocation = "location";
