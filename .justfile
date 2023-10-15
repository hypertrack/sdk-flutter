alias d := docs
alias pt := push-tag
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

push-tag:
    #!/usr/bin/env sh
    if [ $(git symbolic-ref --short HEAD) = "master" ] ; then
        VERSION = $(just version)
        git tag $VERSION
        git push origin $VERSION
    else
        echo "You are not on master branch"
    fi

release: docs
    flutter pub publish --dry-run

update-sdk-latest wrapper_version commit="true" branch="true":
    #!/usr/bin/env sh
    LATEST_IOS=$(curl -s https://cocoapods.org/pods/HyperTrack | grep -m 1 -o "<span>[0-9.]*</span>" | grep -o '[0-9.]\+' | head -n 1)
    LATEST_ANDROID=$(curl -s https://s3-us-west-2.amazonaws.com/m2.hypertrack.com/com/hypertrack/sdk-android/maven-metadata-sdk-android.xml | grep latest | grep -o '[0-9.]\+' | head -n 1)
    just update-sdk {{wrapper_version}} $LATEST_IOS $LATEST_ANDROID {{commit}} {{branch}}

update-sdk-android-latest wrapper_version commit="true" branch="true":
    #!/usr/bin/env sh
    LATEST_ANDROID=$(curl -s https://s3-us-west-2.amazonaws.com/m2.hypertrack.com/com/hypertrack/sdk-android/maven-metadata-sdk-android.xml | grep latest | grep -o '[0-9.]\+' | head -n 1)
    just update-sdk-android {{wrapper_version}} $LATEST_ANDROID {{commit}} {{branch}}

update-sdk-ios-latest wrapper_version commit="true" branch="true":
    #!/usr/bin/env sh
    LATEST_IOS=$(curl -s https://cocoapods.org/pods/HyperTrack | grep -m 1 -o "<span>[0-9.]*</span>" | grep -o '[0-9.]\+' | head -n 1)
    just update-sdk-ios {{wrapper_version}} $LATEST_IOS {{commit}} {{branch}}

update-sdk wrapper_version ios_version android_version commit="true" branch="true":
    #!/usr/bin/env sh
    if [ "{{branch}}" = "true" ] ; then
        git checkout -b update-sdk-ios-{{ios_version}}-android-{{android_version}}
    fi
    just version
    echo "New version is {{wrapper_version}}"
    just update-wrapper-version-file {{wrapper_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -i {{ios_version}} -a {{android_version}}
    echo "Updating HyperTrack SDK iOS to {{ios_version}}"
    just update-sdk-ios-version-file {{ios_version}}
    echo "Updating HyperTrack SDK Android to {{android_version}}"
    just update-sdk-android-version-file {{android_version}}
    just docs
    if [ "{{commit}}" = "true" ] ; then
        git add .
        git commit -m "Update HyperTrack SDK iOS to {{ios_version}} and Android to {{android_version}}"
        git tag {{wrapper_version}}
    fi

update-sdk-android wrapper_version android_version commit="true" branch="true":
    #!/usr/bin/env sh
    if [ "{{branch}}" = "true" ] ; then
        git checkout -b update-sdk-android-{{android_version}}
    fi
    just version
    echo "Updating HyperTrack SDK Android to {{android_version}} on {{wrapper_version}}"
    just update-wrapper-version-file {{wrapper_version}}
    just update-sdk-android-version-file {{android_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -a {{android_version}}
    just docs
    if [ "{{commit}}" = "true" ] ; then
        git add .
        git commit -m "Update HyperTrack SDK Android to {{android_version}}"
        git tag {{wrapper_version}}
    fi

update-sdk-ios wrapper_version ios_version commit="true" branch="true":
    #!/usr/bin/env sh
    if [ "{{branch}}" = "true" ] ; then
        git checkout -b update-sdk-ios-{{ios_version}}
    fi
    just version
    echo "Updating HyperTrack SDK iOS to {{ios_version}} on {{wrapper_version}}"
    just update-wrapper-version-file {{wrapper_version}}
    just update-sdk-ios-version-file {{ios_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -i {{ios_version}}
    just docs
    if [ "{{commit}}" = "true" ] ; then
        git add .
        git commit -m "Update HyperTrack SDK iOS to {{ios_version}}"
        git tag {{wrapper_version}}
    fi

update-sdk-android-version-file android_version:
    ./scripts/update_file.sh android/build.gradle 'def hyperTrackVersion = \".*\"' 'def hyperTrackVersion = \"{{android_version}}\"'

update-sdk-ios-version-file ios_version:
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "'HyperTrack', '.*'" "'HyperTrack', '{{ios_version}}'"

update-wrapper-version-file wrapper_version:
    ./scripts/update_file.sh pubspec.yaml 'version: .*' 'version: {{wrapper_version}}'
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "s.version             = '.*'" "s.version             = '{{wrapper_version}}'"


version:
    cat pubspec.yaml | grep version | grep -o '[0-9.]\+'
