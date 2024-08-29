import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';

class Order {
  const Order(this.isInsideGeofence, this.orderHandle);

  final String orderHandle;
  final Result<bool, LocationError> isInsideGeofence;
}
