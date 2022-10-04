bool deserializeIsTracking(Map<Object?, Object?> response) {
  Map<String, bool> data = response.cast<String, bool>();
  bool? isTracking = data[_keyIsTracking];
  if(isTracking == null) {
    throw Exception("Invalid isTracking response: ${response}");
  }
  return isTracking;
}

bool deserializeIsRunning(Map<Object?, Object?> response) {
  Map<String, bool> data = response.cast<String, bool>();
  bool? isRunning = data[_keyIsRunning];
  if(isRunning == null) {
    throw Exception("Invalid isRunning response: ${response}");
  }
  return isRunning;
}

const _keyIsTracking = "isTracking";
const _keyIsRunning = "isRunning";
