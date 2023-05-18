import 'package:hypertrack_plugin/data_types/location.dart';

class LocationWithDeviation {
  final Location location;
  final double deviation;

  LocationWithDeviation(this.location, this.deviation);
}
