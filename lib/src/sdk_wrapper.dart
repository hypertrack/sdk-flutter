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
const EventChannel _eventChannel =
    EventChannel('$_channelPrefix/trackingState');
const EventChannel _trackingSubscription =
    EventChannel('$_channelPrefix/trackingSubscription');
const EventChannel _availabilitySubscription =
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

  Future<HyperTrack> initialize(String publishableKey) {
    return invokeSdkMethod(SdkMethod.initialize, publishableKey)
        .then((value) => HyperTrack());
  }

  Future<String> getDeviceId() {
    return invokeSdkMethod(SdkMethod.getDeviceId);
  }

  Future<Availability> getAvailability() {
    return invokeSdkMethod(SdkMethod.getAvailability)
        .then((value) => deserializeAvailability(value));
  }

  Future<void> setDeviceName(String name) async {
    await invokeSdkMethod(SdkMethod.setDeviceName, name);
  }

  Future<void> setDeviceMetadata(data) async {
    await invokeSdkMethod(SdkMethod.setDeviceMetadata, data);
  }

  Future<bool> isRunning() {
    return invokeSdkMethod(SdkMethod.isRunning);
  }

  Future<bool> isTracking() {
    return invokeSdkMethod(SdkMethod.isTracking);
  }

  Future<void> startTracking() async {
    await invokeSdkMethod(SdkMethod.start);
  }

  Future<void> stopTracking() async {
    await invokeSdkMethod(SdkMethod.stop);
  }

  Future<void> setAvailability(Availability availability) async {
    invokeSdkMethod(SdkMethod.setAvailability, serializeAvailability(availability));
  }

  // implemented in the platform-specific wrappers
  Future<void> addGeotag(data, expectedLocation) async {
    throw UnimplementedError(_notImplementedError);
  }

  Future<void> syncDeviceSettings() async {
    return invokeSdkMethod(SdkMethod.syncDeviceSettings);
  }

  Future<void> allowMockLocations() {
    return invokeSdkMethod(SdkMethod.allowMockLocations, true);
  }

  Future<void> enableDebugLogging() {
    return invokeSdkMethod(SdkMethod.enableDebugLogging, true);
  }

  Stream<Availability> get onAvailabilityChanged {
    return _availabilitySubscription
        .receiveBroadcastStream()
        .map((event) => deserializeBooleanAvailability(event));
  }

  Stream<TrackingStateChange> get onTrackingStateChanged {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => deserializeTrackingState(event));
  }

  @protected
  Future<T> invokeSdkMethod<T>(SdkMethod method, [dynamic arguments]) {
    return _methodChannel
        .invokeMethod(method.toString(), arguments)
        .then((value) {
      if (value == null) {
        throw Exception("Unexpected null response for ${method.toString()}");
      } else {
        return value;
      }
    });
  }

}
