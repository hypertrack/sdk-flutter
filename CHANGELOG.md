# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2023-06-14

### Changed
- Updated HyperTrack Android SDK to 6.4.2

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
- setTripMarker` replaced with `addGeotag` 

## [0.1.0] - 2020-03-24
#### Added
- Initial release.

[1.1.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.1.2
[1.1.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.1.1
[1.1.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.1.0
[1.0.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/1.0.0
[0.4.3]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.3
[0.4.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.2
[0.4.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.1
[0.4.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.4.0
[0.3.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.3.1
[0.3.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.3.0
[0.2.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.2.1
[0.2.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.2.0
[0.1.9]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.9
[0.1.8]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.8
[0.1.7]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.7
[0.1.6]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.6
[0.1.5]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.5
[0.1.4]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.4
[0.1.3]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.3
[0.1.2]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.2
[0.1.1]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.1
[0.1.0]: https://github.com/hypertrack/sdk-flutter/releases/tag/0.1.0
