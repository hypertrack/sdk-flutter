import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';

class Order {
  Order(this._isInsideGeofence, this.orderHandle);

  final String orderHandle;
  final Future<Result<bool, LocationError>> Function() _isInsideGeofence;

  Future<Result<bool, LocationError>> get isInsideGeofence async {
    return await _isInsideGeofence();
  }
}
