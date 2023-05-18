import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';

import '../../data_types/location.dart';
import 'common.dart';
import 'location.dart';

LocationWithDeviation deserializeLocationWithDeviation(
    Map<Object?, Object?> map) {
  try {
    final data =
        (map[keyValue] as Map<Object?, Object?>).cast<String, Object?>();
    return LocationWithDeviation(
        deserializeLocation(data[_keyLocation]! as Map<Object?, Object?>),
        data[_keyDeviation]! as double);
  } catch (e) {
    throw Exception("Invalid location with deviation $map $e");
  }
}

const _keyLocation = "location";
const _keyDeviation = "deviation";
