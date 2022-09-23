import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/src/sdk_methods.dart';
import 'package:hypertrack_plugin/src/serialization/availability.dart';
import 'package:hypertrack_plugin/src/serialization/tracking_state.dart';
import '../data_types/availability.dart';
import '../data_types/tracking_state.dart';
import '../hypertrack.dart';
import 'android/sdk_wrapper_android.dart';
import 'ios/sdk_wrapper_ios.dart';

const _channelPrefix = 'sdk.hypertrack.com';
const String _notImplementedError =
    "Method is not available for the current platform";

// channel for invoking SDK methods
const _methodChannel = MethodChannel('$_channelPrefix/handle');

// channels for receiving events from the SDK
const EventChannel _trackingStateEventChannel =
    EventChannel('$_channelPrefix/trackingState');
const EventChannel _availabilityEventChannel =
    EventChannel('$_channelPrefix/availabilitySubscription');

abstract class HypertrackSdkWrapper {
  HypertrackSdkWrapper();

  static HypertrackSdkWrapper instance = HypertrackSdkWrapper._getPlatformInstance();

  factory HypertrackSdkWrapper._getPlatformInstance() {
    if (Platform.isAndroid) {
      return HypertrackWrapperAndroid();
    } else if (Platform.isIOS) {
      return HypertrackWrapperIos();
    } else {
      throw Exception("${Platform.operatingSystem} is not supported");
    }
  }

  Future<void> initialize(String publishableKey) {
    return invokeSdkVoidMethod(SdkMethod.initialize, publishableKey);
  }

  Future<String> getDeviceId() {
    return invokeSdkMethod(SdkMethod.getDeviceId);
  }

  Future<Availability> getAvailability() {
    return invokeSdkMethod(SdkMethod.getAvailability)
        .then((value) => deserializeAvailability(value));
  }

  Future<void> setDeviceName(String name) async {
    await invokeSdkVoidMethod(SdkMethod.setDeviceName, name);
  }

  Future<void> setDeviceMetadata(data) async {
    await invokeSdkVoidMethod(SdkMethod.setDeviceMetadata, data);
  }

  Future<bool> isRunning() {
    return invokeSdkMethod(SdkMethod.isRunning);
  }

  Future<bool> isTracking() {
    return invokeSdkMethod(SdkMethod.isTracking);
  }

  Future<void> startTracking() async {
    await invokeSdkVoidMethod(SdkMethod.start);
  }

  Future<void> stopTracking() async {
    await invokeSdkVoidMethod(SdkMethod.stop);
  }

  Future<void> setAvailability(Availability availability) async {
    invokeSdkVoidMethod(SdkMethod.setAvailability, serializeAvailability(availability));
  }

  // implemented in the platform-specific wrappers
  Future<void> addGeotag(data, expectedLocation) async {
    throw UnimplementedError(_notImplementedError);
  }

  Future<void> syncDeviceSettings() async {
    return invokeSdkVoidMethod(SdkMethod.syncDeviceSettings);
  }

  Future<void> allowMockLocations() {
    return invokeSdkVoidMethod(SdkMethod.allowMockLocations, true);
  }

  Future<void> enableDebugLogging() {
    return invokeSdkVoidMethod(SdkMethod.enableDebugLogging, true);
  }

  Stream<Availability> get onAvailabilityChanged {
    return _availabilityEventChannel
        .receiveBroadcastStream()
        .map((event) {
          print(event);
          return deserializeBooleanAvailability(event);
        });
  }

  Stream<TrackingStateChange> get onTrackingStateChanged {
    return _trackingStateEventChannel
        .receiveBroadcastStream()
        .map((event) => deserializeTrackingState(event));
  }

  @protected
  Future<T> invokeSdkMethod<T>(SdkMethod method, [dynamic arguments]) {
    return _methodChannel
        .invokeMethod(method.name, arguments)
        .then((value) {
      if (value == null) {
        throw Exception("Unexpected null response for ${method.toString()}");
      } else {
        return value;
      }
    });
  }

  @protected
  Future<void> invokeSdkVoidMethod(SdkMethod method, [dynamic arguments]) {
    return _methodChannel
        .invokeMethod(method.name, arguments);
  }

}
