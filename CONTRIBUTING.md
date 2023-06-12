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

   - Add the release link to the bottom
   
4. Update badge in README
   
5. Run `just release` to do a release dry-run and is everything OK
   
6. Commit, merge changes and create a version tag (without v)
   
7. Push
   
8. Create a release
    - Release title - version
  
9. Publish Flutter package with `flutter pub publish`

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
