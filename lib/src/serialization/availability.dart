import '../../data_types/availability.dart';

Availability deserializeAvailability(String response) {
  switch (response) {
    case _available:
      {
        return Availability.available;
      }
    case _unavailable:
      {
        return Availability.unavailable;
      }
    default:
      {
        throw Exception("Invalid availability response: ${response}");
      }
  }
}

Availability deserializeBooleanAvailability(bool available) {
  if(available) {
    return Availability.available;
  } else {
    return Availability.unavailable;
  }
}

bool serializeAvailability(Availability availability) {
  switch(availability) {
    case Availability.available:
      return true;
    case Availability.unavailable:
      return false;
  }
}

const _available = "AVAILABLE";
const _unavailable = "UNAVAILABLE";
