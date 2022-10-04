bool deserializeAvailability(Map<Object?, Object?> response) {
    Map<String, bool> data = response.cast<String, bool>();
    bool? availability = data[_keyAvailability];
    if (availability == null) {
      throw Exception("Invalid availability response: ${response}");
    }
    return availability;
}

Map<String, bool> serializeAvailability(bool available) {
  return { _keyAvailability: available };
}

const _keyAvailability = "available";
