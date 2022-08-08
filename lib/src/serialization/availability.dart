import 'common.dart';

bool deserializeAvailability(Map<Object?, Object?> response) {
    Map<String, dynamic> data = response.cast<String, dynamic>();
    bool? availability = data[keyValue];
    if (data[keyType] != _typeAvailability || availability == null) {
      throw Exception("Invalid availability response: ${response}");
    }
    return availability;
}

Map<String, dynamic> serializeAvailability(bool available) {
  return {
    keyType: _typeAvailability,
    keyValue: available
  };
}

const _typeAvailability = "isAvailable";
