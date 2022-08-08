import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/src/serialization/hypertrack_error.dart';

import 'common.dart';

LocationError deserializeLocationError(Map<Object?, Object?> response) {
  try {
    Map<String, dynamic> data = response.cast<String, dynamic>();
    final String type = data[keyType];
    switch (type) {
      case _typeNotRunning:
        return LocationError.notRunning();
      case _typeStarting:
        return LocationError.starting();
      case _typeErrors:
        return LocationError.errors(deserializeTrackingErrors(data[keyValue]));
      default:
        throw Exception("Invalid location error response: ${response}");
    }
  } catch (e) {
    throw Exception("Invalid location error response: ${response} ${e}");
  }
}

const _typeNotRunning = "notRunning";
const _typeStarting = "starting";
const _typeErrors = "errors";
