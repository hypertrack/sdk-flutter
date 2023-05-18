import '../../data_types/result.dart';
import 'common.dart';

Result<Map<Object?, Object?>, Map<Object?, Object?>> deserializeResult(
    Map<Object?, Object?> response) {
  try {
    Map<String, dynamic> data = response.cast<String, dynamic>();
    switch (data[keyType]) {
      case _typeSuccess:
        return Result.success(data[keyValue]);
      case _typeFailure:
        return Result.error(data[keyValue]);
      default:
        throw Exception("Invalid location response: ${response}");
    }
  } catch (e) {
    throw Exception("Invalid location response: ${response} $e");
  }
}

const _typeSuccess = "success";
const _typeFailure = "failure";
