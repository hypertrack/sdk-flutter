alias d := docs
alias r := release
alias us := update-sdk
alias usa := update-sdk-android
alias usal := update-sdk-android-latest
alias usi := update-sdk-ios
alias usil := update-sdk-ios-latest
alias usl := update-sdk-latest
alias v := version

docs: lint
    dart doc
    cp -R doc/api/ docs
    rm -r doc

lint:
    ktlint --format .

release: lint docs
    flutter pub publish --dry-run

update-sdk-latest wrapper_version commit="false":
    #!/usr/bin/env sh
    LATEST_IOS=$(curl -s https://cocoapods.org/pods/HyperTrack | grep -m 1 -o "<span>[0-9.]*</span>" | grep -o '[0-9.]\+' | head -n 1)
    LATEST_ANDROID=$(curl -s https://s3-us-west-2.amazonaws.com/m2.hypertrack.com/com/hypertrack/sdk-android/maven-metadata-sdk-android.xml | grep latest | grep -o '[0-9.]\+' | head -n 1)
    just update-sdk {{wrapper_version}} $LATEST_IOS $LATEST_ANDROID
    if [ "{{commit}}" = "true" ] ; then
        git add .
        git commit -m "Update SDK to $LATEST_IOS and $LATEST_ANDROID"
        git tag {{wrapper_version}}
    fi

update-sdk-android-latest wrapper_version:
    #!/usr/bin/env sh
    LATEST_ANDROID=$(curl -s https://s3-us-west-2.amazonaws.com/m2.hypertrack.com/com/hypertrack/sdk-android/maven-metadata-sdk-android.xml | grep latest | grep -o '[0-9.]\+' | head -n 1)
    just update-sdk-android {{wrapper_version}} $LATEST_ANDROID

update-sdk-ios-latest wrapper_version:
    #!/usr/bin/env sh
    LATEST_IOS=$(curl -s https://cocoapods.org/pods/HyperTrack | grep -m 1 -o "<span>[0-9.]*</span>" | grep -o '[0-9.]\+' | head -n 1)
    just update-sdk-ios {{wrapper_version}} $LATEST_IOS

update-sdk wrapper_version ios_version android_version:
    just version
    echo "New version is {{wrapper_version}}"
    just update-wrapper-version-file {{wrapper_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -i {{ios_version}} -a {{android_version}}
    echo "Updating HyperTrack SDK iOS to {{ios_version}}"
    just update-sdk-ios-version-file {{ios_version}}
    echo "Updating HyperTrack SDK Android to {{android_version}}"
    just update-sdk-android-version-file {{android_version}}

update-sdk-android wrapper_version android_version:
    just version
    echo "Updating HyperTrack SDK Android to {{android_version}} on {{wrapper_version}}"
    just update-wrapper-version-file {{wrapper_version}}
    just update-sdk-android-version-file {{android_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -a {{android_version}}

update-sdk-ios wrapper_version ios_version:
    just version
    echo "Updating HyperTrack SDK iOS to {{ios_version}} on {{wrapper_version}}"
    just update-wrapper-version-file {{wrapper_version}}
    just update-sdk-ios-version-file {{ios_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -i {{ios_version}}

update-sdk-android-version-file android_version:
    ./scripts/update_file.sh android/build.gradle 'def hyperTrackVersion = \".*\"' 'def hyperTrackVersion = \"{{android_version}}\"'

update-sdk-ios-version-file ios_version:
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "'HyperTrack', '.*'" "'HyperTrack', '{{ios_version}}'"

update-wrapper-version-file wrapper_version:
    ./scripts/update_file.sh pubspec.yaml 'version: .*' 'version: {{wrapper_version}}'
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "s.version             = '.*'" "s.version             = '{{wrapper_version}}'"


version:
    cat pubspec.yaml | grep version
