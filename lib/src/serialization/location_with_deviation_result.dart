import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';
import 'package:hypertrack_plugin/src/serialization/result.dart';

import '../../data_types/result.dart';
import 'location_error.dart';
import 'location_with_deviation.dart';

Result<LocationWithDeviation, LocationError>
    deserializeLocationWithDeviationResult(Map<Object?, Object?> response) {
  Result<Map<Object?, Object?>, Map<Object?, Object?>> result =
      deserializeResult(response);
  if (result is Success<Map<Object?, Object?>, Map<Object?, Object?>>) {
    return Result.success(deserializeLocationWithDeviation(result.value));
  } else if (result is Error<Map<Object?, Object?>, Map<Object?, Object?>>) {
    return Result.error(deserializeLocationError(result.error));
  } else {
    throw Exception("Illegal argument: ${response}");
  }
}
