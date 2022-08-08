# Contributing

## FAQ

### How to update the HyperTrack SDK version and make a release?

1. Update SDK version

    - android
        - android/build.gradle
            - implementation 'com.hypertrack:hypertrack:**version**
    - ios
        - hypertrack_plugin.podspec
            - s.dependency 'HyperTrack/Objective-C', '**version**'

2. Increment wrapper version
    - pubspec.yaml
        - version
    - ios/hypertrack_plugin.podspec

3. Update CHANGELOG
4. Update badge in README
5. Commit and create a version tag (without v)
6. Push
7. Create a release
    - Release title - version
9. Publish Flutter package
    1. flutter pub publish --dry-run
        - to test is everything OK with release
    2. flutter pub publish

### How to change build config

#### Android

- compileSdkVersion
  - android/build.gradle
    - `android {}`
      - compileSdkVersion 

- minSdkVersion
  - android/build.gradle
    - `defaultConfig {}`
       - minSdkVersion 

- platform version (flutter)
  - pubspec.yaml
    - environment:
        - sdk: 