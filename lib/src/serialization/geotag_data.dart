import 'dart:math';

import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location.dart';
import 'package:hypertrack_plugin/src/serialization/location.dart';

Map<String, dynamic> serializeGeotagData(
    JSONObject data, Location? expectedLocation) {
  if (expectedLocation == null) {
    return {_keyData: data.serialize()};
  } else {
    return {
      _keyData: data.serialize(),
      _keyExpectedLocation: serializeLocation(expectedLocation)
    };
  }
}

const _keyData = "data";
const _keyExpectedLocation = "expectedLocation";
