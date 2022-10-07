import 'package:hypertrack_plugin/data_types/hypertrack_error.dart';

class LocationError {
  LocationError._();

  factory LocationError.notRunning() = NotRunning;
  factory LocationError.starting() = Starting;
  factory LocationError.errors(Set<HyperTrackError> errors) = Errors;

  @override
  String toString() {
    final instance = this;
    if(instance is NotRunning) {
      return "notRunning";
    } else if(instance is Starting) {
      return "starting";
    } else if(instance is Errors) {
      return "[${instance.errors}]";
    } else {
      return super.toString();
    }
  }
}

class NotRunning extends LocationError {
  NotRunning(): super._();
}

class Starting extends LocationError {
  Starting(): super._();
}

class Errors extends LocationError {
  Set<HyperTrackError> errors;

  Errors(this.errors): super._();
}
