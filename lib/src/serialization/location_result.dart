import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/serialization/common.dart';
import 'package:hypertrack_plugin/src/serialization/location_error.dart';
import 'package:hypertrack_plugin/src/serialization/result.dart';

import '../../data_types/hypertrack_error.dart';
import '../../data_types/location.dart';
import 'location.dart';

Result<Location, LocationError> deserializeLocationResult(
    Map<Object?, Object?> response) {
  Result<Map<Object?, Object?>, Map<Object?, Object?>> result =
      deserializeResult(response);
  if (result is Success<Map<Object?, Object?>, Map<Object?, Object?>>) {
    return Result.success(deserializeLocation(result.value));
  } else if (result is Error<Map<Object?, Object?>, Map<Object?, Object?>>) {
    return Result.error(deserializeLocationError(result.error));
  } else {
    throw Exception("Illegal argument: ${response}");
  }
}
