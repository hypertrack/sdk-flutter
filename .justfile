alias d := docs
alias r := release
alias us := update-sdk
alias usa := update-sdk-android
alias usi := update-sdk-ios
alias v := version

docs: lint
    dart doc
    cp -R doc/api/ docs
    rm -r doc

lint:
    ktlint --format .

release: lint docs
    flutter pub publish --dry-run

update-sdk wrapper_version ios_version android_version:
    just version
    echo "New version is {{wrapper_version}}"
    just update-wrapper-version-file {{wrapper_version}}
    just update-changelog-file {{wrapper_version}} {{ios_version}} {{android_version}}
    echo "Updating HyperTrack SDK iOS to {{ios_version}}"
    just update-sdk-ios-version-file {{ios_version}}
    echo "Updating HyperTrack SDK Android to {{android_version}}"
    just update-sdk-android-version-file {{android_version}}

update-sdk-android wrapper_version android_version:
    just version
    echo "Updating HyperTrack SDK Android to {{android_version}} on {{wrapper_version}}"
    just update-sdk-android-version-file {{android_version}}

update-sdk-ios wrapper_version ios_version:
    just version
    echo "Updating HyperTrack SDK iOS to {{ios_version}} on {{wrapper_version}}"
    just update-sdk-ios-version-file {{ios_version}}

update-sdk-android-version-file android_version:
    ./scripts/update_file.sh android/build.gradle 'def hyperTrackVersion = \".*\"' 'def hyperTrackVersion = \"{{android_version}}\"'

update-sdk-ios-version-file ios_version:
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "'HyperTrack', '.*'" "'HyperTrack', '{{ios_version}}'"

update-wrapper-version-file wrapper_version:
    ./scripts/update_file.sh pubspec.yaml 'version: .*' 'version: {{wrapper_version}}'
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "s.version             = '.*'" "s.version             = '{{wrapper_version}}'"

update-changelog-file wrapper_version ios_version android_version:
    ./scripts/update_changelog.sh {{wrapper_version}} {{ios_version}} {{android_version}}

version:
    cat pubspec.yaml | grep version
