import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';

import '../../data_types/location.dart';
import 'common.dart';
import 'location.dart';

LocationWithDeviation deserializeLocationWithDeviation(
    Map<Object?, Object?> map) {
  try {
    final data = (map[keyValue] as Map<Object?, Object?>)
        .cast<String, Object?>()
        .cast<String, double>();
    return LocationWithDeviation(
        Location(data[keyLatitude]!, data[keyLongitude]!),
        data[_keyDeviation]!);
  } catch (e) {
    throw Exception("Invalid location $map $e");
  }
}

const _keyDeviation = "deviation";
