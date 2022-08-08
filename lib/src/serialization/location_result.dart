import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/serialization/common.dart';
import 'package:hypertrack_plugin/src/serialization/location_error.dart';

import '../../data_types/hypertrack_error.dart';
import '../../data_types/location.dart';

Result<Location, LocationError> deserializeLocationResult(
    Map<Object?, Object?> response) {
  try {
    Map<String, dynamic> data = response.cast<String, dynamic>();
    switch (data[keyType]) {
      case _typeSuccess:
        return Result.success(deserializeLocation(data[keyValue]));
      case _typeFailure:
        return Result.error(deserializeLocationError(data[keyValue]));
      default:
        throw Exception("Invalid location response: ${response}");
    }
  } catch (e) {
    throw Exception("Invalid location response: ${response} $e");
  }
}

Location deserializeLocation(Map<Object?, Object?> map) {
  try {
    final data = (map[keyValue] as Map<Object?, Object?>).cast<String, double>();
    return Location(
        data[_keyLatitude]!,
        data[_keyLongitude]!
    );
  } catch(e) {
    throw Exception("Invalid location $map $e");
  }
}

const _typeSuccess = "success";
const _typeFailure = "failure";
const _keyLatitude = "latitude";
const _keyLongitude = "longitude";
