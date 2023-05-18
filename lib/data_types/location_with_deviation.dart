import 'package:hypertrack_plugin/data_types/location.dart';

class LocationWithDeviation {
  final Location location;
  final double deviation;

  LocationWithDeviation(this.location, this.deviation);

  /// @nodoc
  @override
  String toString() {
    return "{location: $location, deviation: $deviation}";
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}
