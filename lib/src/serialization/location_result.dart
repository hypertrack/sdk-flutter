import 'package:hypertrack_plugin/data_types/error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/serialization/error.dart';

import '../../data_types/location.dart';

Result<Location, HyperTrackError> deserializeLocationResult(
    Map<Object?, Object?> response) {
  Map<String, dynamic> data = response.cast<String, dynamic>();
  if (data.containsKey(_keyLocation)) {
    return Result.success(deserializeLocation(data));
  } else if (data.containsKey(keyTrackingError)) {
    return Result.error(deserializeTrackingError(data));
  } else {
    throw Exception("Invalid location response: ${response}");
  }
}

Location deserializeLocation(Map<String, dynamic> map) {
  return Location(
      map[_keyLocation][_keyLatitude],
      map[_keyLocation][_keyLongitude]
  );
}

const String _keyLocation = "location";
const String _keyLatitude = "latitude";
const String _keyLongitude = "longitude";
