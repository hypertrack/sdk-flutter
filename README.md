
# HyperTrack SDK Flutter plugin 

![GitHub](https://img.shields.io/github/license/hypertrack/sdk-flutter.svg)
[![Pub Version](https://img.shields.io/pub/v/hypertrack_plugin?color=blueviolet)](https://pub.dev/packages/hypertrack_plugin)
[![iOS SDK](https://img.shields.io/badge/iOS%20SDK-4.12.3-brightgreen.svg)](https://cocoapods.org/pods/HyperTrack)
![Android SDK](https://img.shields.io/badge/Android%20SDK-6.3.0-brightgreen.svg)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app in a reliable and battery efficient way.

HyperTrack SDK Flutter plugin is a wrapper around native iOS and Android SDKs that allows to integrate them into Flutter apps.

For information about how to get started with HyperTrack SDK for Flutter, please visit this [HyperTrack Guide](https://hypertrack.com/docs/install-sdk-flutter).

## Wanna try it out??

Head over to [Quickstart Flutter](https://github.com/hypertrack/quickstart-flutter)
- Clone the repo to your device
- If you want to change where the HyperTrack plugin comes from, change that in the pubspec.yaml file as below

        ...
        dependencies:
    	hypertrack_plugin:
	    	git:
				url: https://github.com/hypertrack/sdk-flutter.git  
				ref: master
	- Replace url with your desired remote of Hypertrack plugin
	- ref can be replaced either with branch name or the commit ID for the same.
- If you want to consume the HyperTrack plugin on your local machine use the path parameter instead.
	- Replace url with your desired remote of Hypertrack plugin
	asdasd
 - If you want to consume the local package instead, use path parameter instead.
	````
	...
	dependencies:
		hypertarck_plugin:
			path: ../  #Assuming you are running quickstart in root of the wrapper
	````
- Run flutter run with **--ignore-deprecation** flag

## How to update HyperTrack SDK version?

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

## How to change build config
1. compileSdkVersion
  - change it in android/build.gradle
  - android {
    compileSdkVersion 

2. minSdkVersion
  - defaultConfig {
        minSdkVersion 

3. platform version (flutter)
  - In pubspec.yaml file
  - environment:
  sdk: 
