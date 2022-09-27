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

bool serializeAvailability(Availability availability) {
  switch(availability) {
    case Availability.available:
      return true;
    case Availability.unavailable:
      return false;
  }
}

const _available = "available";
const _unavailable = "unavailable";
