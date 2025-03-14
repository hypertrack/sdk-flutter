# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.2] - 2025-03-06

### Changed

- Updated HyperTrack SDK iOS to [5.11.2](https://github.com/hypertrack/sdk-ios/releases/tag/5.11.2)
- Updated HyperTrack SDK Android to [7.11.3](https://github.com/hypertrack/sdk-android/releases/tag/7.11.3)

## [3.0.1] - 2025-03-04

### Changed

- Updated HyperTrack SDK iOS to [5.11.1](https://github.com/hypertrack/sdk-ios/releases/tag/5.11.1)
- Updated HyperTrack SDK Android to [7.11.2](https://github.com/hypertrack/sdk-android/releases/tag/7.11.2)

## [3.0.0] - 2025-02-06

### Changed

- `Order.isInsideGeofence` is now an async fuction that returns the value at the moment when it called (instead of the constant value at the time of `getOrders` being called)
- Updated HyperTrack SDK iOS to [5.11.0](https://github.com/hypertrack/sdk-ios/releases/tag/5.11.0)
- Updated HyperTrack SDK Android to [7.11.0](https://github.com/hypertrack/sdk-android/releases/tag/7.11.0)

### Fixed

- Wrong order of Orders in `HyperTrack.getOrders()` on iOS
- Error on `HyperTrack.getOrders()`/`HyperTrack.subscribeToOrders()` on Android when assigning multiple orders to the worker

## [2.7.0] - 2025-01-21

### Added

- New `HyperTrack.allowMockLocation` and `HyperTrack.setAllowMockLocation()` methods which can be used to allow mocking location data.
  - Check the [Test with mock locations](https://hypertrack.com/docs/mock-location) guide for more information.
    - Note: To avoid issues related to race conditions in your code use this API **only if** modifying the compiled `HyperTrackAllowMockLocation` AndroidManifest.xml/Info.plist value is insufficient for your needs.
      - Example: if for some reason you aren't able to recompile with `HyperTrackAllowMockLocation` set to `YES`/`true` for your prod app QA mock location tests and need to set up the value in runtime.
- Gradle 8 support

### Changed

- Updated HyperTrack SDK iOS to [5.10.0](https://github.com/hypertrack/sdk-ios/releases/tag/5.10.0)
- Updated HyperTrack SDK Android to [7.10.0](https://github.com/hypertrack/sdk-android/releases/tag/7.10.0)

## [2.6.1] - 2024-12-05

### Changed

- Updated HyperTrack SDK iOS to [5.9.1](https://github.com/hypertrack/sdk-ios/releases/tag/5.9.1)
- Updated HyperTrack SDK Android to [7.9.1](https://github.com/hypertrack/sdk-android/releases/tag/7.9.1)

## [2.6.0] - 2024-11-22

### Changed

- Updated HyperTrack SDK iOS to [5.9.0](https://github.com/hypertrack/sdk-ios/releases/tag/5.9.0)
- Updated HyperTrack SDK Android to [7.9.0](https://github.com/hypertrack/sdk-android/releases/tag/7.9.0)

## [2.5.2] - 2024-11-13

### Changed

- Updated HyperTrack SDK iOS to [5.8.1](https://github.com/hypertrack/sdk-ios/releases/tag/5.8.1)
- Updated HyperTrack SDK Android to [7.8.4](https://github.com/hypertrack/sdk-android/releases/tag/7.8.4)

## [2.5.1] - 2024-09-24

### Changed

- Updated HyperTrack SDK Android to [7.8.3](https://github.com/hypertrack/sdk-android/releases/tag/7.8.3)

## [2.5.0] - 2024-09-04

### Added

- Support for Motion & Activity detection
  - If your app asks for permission and the user grants it, you will have better activity detection in polylines

### Changed

- Updated HyperTrack SDK iOS to [5.8.0](https://github.com/hypertrack/sdk-ios/releases/tag/5.8.0)
- Updated HyperTrack SDK Android to [7.8.2](https://github.com/hypertrack/sdk-android/releases/tag/7.8.2)

## [2.4.0] - 2024-08-27

### Added

- Support for on-device geofencing via new `HyperTrack.orders["my_order"].isInsideGeofence` property
  - To learn more about how to best use this new feature see our guide
    here: [Verify shift presence before starting work](https://developer.hypertrack.com/docs/clock-in-out-tagging#verify-shift-presence-before-starting-work)

```dart
    // check worker presence synchronously
    var activeOrders = await HyperTrack.orders;
    Order? currentOrder = activeOrders["current_order"];
    if (currentOrder != null) {
      handlePresence(currentOrder.isInsideGeofence);
    } else {
      print("'current_order' not found");
    }

    // or subscribe to the changes in orders to get the status updates
    HyperTrack.ordersSubscription.listen((orders) {
      Order? currentOrder = orders["current_order"];
      if (currentOrder != null) {
        handlePresence(currentOrder.isInsideGeofence);
      } else {
        print("'current_order' not found");
      }
    });

    // handle worker presence inside the order destination geofence
    void handlePresence(Result<bool, LocationError> isInsideGeofence) {
      switch (isInsideGeofence.runtimeType) {
        case Success:
          if ((isInsideGeofence as Success).value) {
            // allow worker to clock in for the shift
          } else {
            // "to clock in you must be at order destination"
          }
          break;
        case Failure:
          // resolve errors to check for presence
          break;
      }
    }
```

### Changed

- Updated HyperTrack SDK iOS to [5.7.0](https://github.com/hypertrack/sdk-ios/releases/tag/5.7.0)
- Updated HyperTrack SDK Android
  to [7.7.0](https://github.com/hypertrack/sdk-android/releases/tag/7.7.0)

## [2.3.0] - 2024-06-22

### Added

- New `setWorkerHandle` and `getWorkerHandle` can be used to identify workers
  - We observed our customers identify worker devices via `HyperTrack.metadata`, so we decided to
    make it a first class citizen in our API.
  - If you previously used `metadata` to identify workers, we suggest using `workerHandle` for
    this purpose instead.

### Changed

- Updated HyperTrack SDK iOS to [5.6.0](https://github.com/hypertrack/sdk-ios/releases/tag/5.6.0)
- Updated HyperTrack SDK Android
  to [7.6.0](https://github.com/hypertrack/sdk-android/releases/tag/7.6.0)

## [2.2.3] - 2024-05-24

### Changed

- Updated HyperTrack SDK Android
  to [7.5.5](https://github.com/hypertrack/sdk-android/releases/tag/7.5.5)

## [2.2.2] - 2024-05-14

### Changed

- Updated HyperTrack SDK iOS to [5.5.4](https://github.com/hypertrack/sdk-ios/releases/tag/5.5.4)
- Updated HyperTrack SDK Android
  to [7.5.4](https://github.com/hypertrack/sdk-android/releases/tag/7.5.4)

## [2.2.1] - 2024-05-03

### Changed

- Updated HyperTrack SDK iOS to [5.5.3](https://github.com/hypertrack/sdk-ios/releases/tag/5.5.3)

## [2.2.0] - 2024-04-24

### Changed

- New `addGeotag` and `addGeotagWithExpectedLocation` methods signature that have `orderHandle`
  and `orderStatus` parameters. You can use this API when users need to clock in/out of work in your
  app to honor their work time (
  see [Clock in/out Tagging](https://hypertrack.com/docs/clock-inout-tracking#add-clock-inout-events-to-a-shift-timeline)
  guide for more info)
- Updated HyperTrack SDK iOS to [5.5.2](https://github.com/hypertrack/sdk-ios/releases/tag/5.5.2)
- Updated HyperTrack SDK Android
  to [7.5.3](https://github.com/hypertrack/sdk-android/releases/tag/7.5.3)

## [2.1.2] - 2024-02-27

### Changed

- Updated HyperTrack SDK Android
  to [7.4.3](https://github.com/hypertrack/sdk-android/releases/tag/7.4.3)

## [2.1.1] - 2024-02-14

### Changed

- Updated HyperTrack SDK iOS to [5.4.1](https://github.com/hypertrack/sdk-ios/releases/tag/5.4.1)
- Updated HyperTrack SDK Android
  to [7.4.2](https://github.com/hypertrack/sdk-android/releases/tag/7.4.2)

## [2.1.0] - 2024-01-29

### Changed

- Updated HyperTrack SDK iOS to [5.4.0](https://github.com/hypertrack/sdk-ios/releases/tag/5.4.0)
- Updated HyperTrack SDK Android
  to [7.4.0](https://github.com/hypertrack/sdk-android/releases/tag/7.4.0)

## [2.0.4] - 2023-12-01

### Changed

- Updated HyperTrack SDK iOS to [5.0.8](https://github.com/hypertrack/sdk-ios/releases/tag/5.0.8)
- Updated HyperTrack SDK Android
  to [7.0.10](https://github.com/hypertrack/sdk-android/releases/tag/7.0.10)
- `minSdkVersion` from 23 to 19 for Android

## [2.0.3] - 2023-11-20

### Changed

- Updated HyperTrack SDK iOS to [5.0.7](https://github.com/hypertrack/sdk-ios/releases/tag/5.0.7)
- Updated HyperTrack SDK Android
  to [7.0.9](https://github.com/hypertrack/sdk-android/releases/tag/7.0.9)

## [2.0.2] - 2023-11-10

### Changed

- Updated HyperTrack SDK iOS to [5.0.6](https://github.com/hypertrack/sdk-ios/releases/tag/5.0.6)
- Updated HyperTrack SDK Android
  to [7.0.8](https://github.com/hypertrack/sdk-android/releases/tag/7.0.8)

## [2.0.1] - 2023-10-16

### Changed

- Updated HyperTrack SDK iOS to [5.0.4](https://github.com/hypertrack/sdk-ios/releases/tag/5.0.4)
- Updated HyperTrack SDK Android
  to [7.0.6](https://github.com/hypertrack/sdk-android/releases/tag/7.0.6)

### Fixed

- Error on calling `HyperTrack.errors`

## [2.0.0] - 2023-10-02

### Added

- `locate()` to ask for one-time user location
- `locationSubcription` to subscribe to user location updates
- `errors` getter
- `name` getter
- `metadata` getter
- HyperTrackError types:
  - `noExemptionFromBackgroundStartRestrictions`
  - `permissionsNotificationsDenied`

### Changed

- Updated HyperTrack Android SDK
  to [7.0.3](https://github.com/hypertrack/sdk-android/blob/master/CHANGELOG.md#703---2023-09-28)
- Add Android SDK plugins (`location-services-google` and `push-service-firebase`)
- Updated HyperTrack iOS SDK to [5.0.2](https://github.com/hypertrack/sdk-ios/releases/tag/5.0.2)
- The whole HyperTrack API is now static
- Changed the way to provide publishableKey (
  - You need to add `HyperTrackPublishableKey` `meta-data` item to your `AndroidManifest.xml` and
    the same entry to `Info.plist`)
- Renamed HyperTrackError types:
  - `gpsSignalLost` to `locationSignalLost`
  - `locationPermissionsDenied` to `permissionsLocationDenied`
  - `locationPermissionsInsufficientForBackground`
    to `permissionsLocationInsufficientForBackground`
  - `locationPermissionsNotDetermined` to `permissionsLocationNotDetermined`
  - `locationPermissionsProvisional` to `locationPermissionsProvisional`
  - `locationPermissionsReducedAccuracy` to `permissionsLocationReducedAccuracy`
  - `locationPermissionsRestricted` to `permissionsLocationRestricted`
- Renamed `setAvailability()` to `setIsAvailable(boolean)`
- Changed `startTracking()` and `stopTracking()` to `setIsTracking(boolean)`
- Renamed `onTrackingChanged` to `isTrackingSubscription`
- Renamed `onAvailabilityChanged` to `isAvailableSubscription`
- Renamed `onError` to `errorsSubscription`
- Renamed `JSONValue` to `JSON`

### Removed

- `initialize()` method (the API is now static)
- Motion Activity permissions are not required for tracking anymore
- HyperTrackError types:
  - `motionActivityPermissionsDenied`
  - `motionActivityServicesDisabled`
  - `motionActivityServicesUnavailable`
  - `motionActivityPermissionsRestricted`
  - `networkConnectionUnavailable`
- `sync()` method

## [1.1.3] - 2023-06-16

### Changed

- Updated HyperTrack iOS SDK to 4.16.1

## [1.1.2] - 2023-06-14

### Changed

- Updated HyperTrack Android SDK to 6.4.2
- Updated Kotlin to 1.6.21

## [1.1.1] - 2023-06-01

### Changed

- Updated HyperTrack iOS SDK to 4.16.0

## [1.1.0] - 2023-05-18

### Added

- `addGeotag` with expected location
- `automaticallyRequestPermissions` param to SDK initialization
- JSONNull type to JSONValue

### Changed

- Updated HyperTrack iOS SDK to 4.15.0

### Fixed

- String representation of errors in subscribeToErrors result

## [1.0.0] - 2023-02-17

### Changed

- Updated HyperTrack iOS SDK to 4.14.0
- Updated HyperTrack Android SDK to 6.4.0
- `syncDeviceSettings()` renamed to `sync()`
- `setDeviceName()` renamed to `setName()`
- `setDeviceMetadata()` renamed to `setMetadata()`
- `start()` renamed to `startTracking()`
- `stop()` renamed to `stopTracking()`

### Added

- `initialize()` configuration params for
  - Debug logging
  - Background location permissions request for Android
  - Mock locations
- `onAvailabilityChanged` stream
- `onError` stream
- Location result for `addGeotag`

### Removed

- `getLatestLocation()`
- `allowMockLocations()` (use `initialize()` param `allowMockLocations` instead)
- `enableDebugLogging()` (use `initialize()` param `loggingEnabled` instead)
- `getRunnigStatus()`
- 'expectedLocation' param from 'addGeotag()'

## [0.4.3] - 2022-09-16

#### Changed

- Android SDK updated to 6.3.0

## [0.4.2] - 2022-08-30

#### Changed

- Android SDK updated to 6.2.2

## [0.4.1] - 2022-07-19

#### Changed

- Android SDK updated to 6.2.0
- iOS SDK updated to 4.12.3

## [0.4.0] - 2022-07-07

#### Changed

- Android SDK updated to 6.1.4

## [0.3.1] - 2022-07-05

#### Fixed

- Android null type safety plugin fixes

## [0.3.0] - 2021-11-17

#### Changed

- Android SDK updated to 5.4.5

## [0.2.1] - 2021-07-07

#### Changed

- No code changes. Package metadata was updated to improve scoring.

## [0.2.0] - 2021-07-07

#### Added

- Dart nullability support added to comply with Flutter 2 requirements

#### Changed

- Android SDK updated to 5.2.5

## [0.1.9] - 2021-05-07

#### Changed

- Android SDK updated to 4.12.0

## [0.1.8] - 2021-04-07

#### Changed

- Android SDK updated to 4.11.0

## [0.1.7] - 2020-12-24

#### Changed

- Android SDK updated to 4.9.0
- Firebase conflicts were fixed.

## [0.1.6] - 2020-12-23

#### Fixed

- iOS plugin runtime error notification.

#### Changed

- iOS SDK version updated to 4.7.0

## [0.1.5] - 2020-12-16

#### Fixed

- iOS plugin, incorrect `permissions_error` notification.

## [0.1.4] - 2020-11-20

#### Fixed

- Firebase tokens and messages forwarding.

#### Changed

- iOS SDK version updated to 4.6.0

## [0.1.3] - 2020-11-02

#### Changed

- Android SDK version updated to 4.8.0

## [0.1.2] - 2020-09-28

#### Changed

- Android SDK version updated to 4.6.0

## [0.1.1] - 2020-06-18

#### Changed

- Android SDK version updated to 4.4.1
- setTripMarker`replaced with`addGeotag`

## [0.1.0] - 2020-03-24

#### Added

- Initial release.

[0.1.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.0
[0.1.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.1
[0.1.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.2
[0.1.3]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.3
[0.1.4]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.4
[0.1.5]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.5
[0.1.6]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.6
[0.1.7]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.7
[0.1.8]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.8
[0.1.9]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.9
[0.2.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.2.0
[0.2.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.2.1
[0.3.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.3.0
[0.3.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.3.1
[0.4.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.0
[0.4.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.1
[0.4.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.2
[0.4.3]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.3
[1.0.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.0.0
[1.1.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.1.0
[1.1.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.1.1
[1.1.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.1.2
[1.1.3]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.1.3
[2.0.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.0.0
[2.0.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.0.1
[2.0.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.0.2
[2.0.3]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.0.3
[2.0.4]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.0.4
[2.1.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.1.0
[2.1.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.1.1
[2.1.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.1.2
[2.2.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.2.0
[2.2.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.2.1
[2.2.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.2.2
[2.2.3]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.2.3
[2.3.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.3.0
[2.4.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.4.0
[2.5.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.5.0
[2.5.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.5.1
[2.5.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.5.2
[2.6.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.6.0
[2.6.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.6.1
[2.7.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/2.7.0
[3.0.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/3.0.0
[3.0.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/3.0.1
[3.0.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/3.0.2
