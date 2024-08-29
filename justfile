alias b := build
alias cncfrn := copy-native-code-from-react-native
alias d := docs
alias f := format
alias gd := get-dependencies
alias pt := push-tag
alias od := open-docs
alias ogp := open-github-prs
alias ogr := open-github-releases
alias r := release
alias s := setup
alias us := update-sdk
alias usa := update-sdk-android
alias usal := update-sdk-android-latest
alias usi := update-sdk-ios
alias usil := update-sdk-ios-latest
alias usl := update-sdk-latest
alias v := version

# Source: https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# \ are escaped
SEMVER_REGEX := "(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?"

# MAKE SURE YOU HAVE
# #!/usr/bin/env sh
# set -e
# AT THE TOP OF YOUR RECIPE
_ask-confirm:
  @bash -c 'read confirmation; if [[ $confirmation != "y" && $confirmation != "Y" ]]; then echo "Okay 😮‍💨 😅"; exit 1; fi'

build: get-dependencies docs

copy-native-code-from-react-native:
    cp -rf ../sdk-react-native/sdk/android/src/main/java/com/reactnativehypertracksdk/common android/src/main/kotlin/com/hypertrack/sdk/flutter/
    cp -rf ../sdk-react-native/sdk/ios/common ios/Classes/

docs: format
    @echo "Docs generation usually takes ~1 minute"
    dart doc --output=docs > /dev/null

format: 
    ktlint --format android/src/main/

get-dependencies:
    flutter pub get

_latest-android:
    @curl -s https://s3-us-west-2.amazonaws.com/m2.hypertrack.com/com/hypertrack/sdk-android/maven-metadata-sdk-android.xml | grep latest | grep -o -E '{{SEMVER_REGEX}}' | head -n 1

_latest-ios:
    @curl -s https://cocoapods.org/pods/HyperTrack | grep -m 1 -o -E "HyperTrack <span>{{SEMVER_REGEX}}" | grep -o -E '{{SEMVER_REGEX}}' | head -n 1

open-docs:
    open docs/index.html

_open-github-release-data:
    code CHANGELOG.md
    just open-github-releases

open-github-prs:
    open "https://github.com/hypertrack/sdk-flutter/pulls"

open-github-releases:
    open "https://github.com/hypertrack/sdk-flutter/releases"

push-tag:
    #!/usr/bin/env sh
    if [ $(git symbolic-ref --short HEAD) = "master" ] ; then
        VERSION=$(just version)
        git tag $VERSION
        git push origin $VERSION
        just _open-github-release-data
    else
        echo "You are not on master branch"
    fi

release type="dry-run": setup
    #!/usr/bin/env sh
    set -euo pipefail
    VERSION=$(just version)
    if [ "{{type}}" = "publish" ] ; then
        BRANCH=$(git branch --show-current)
        if [ $BRANCH != "master" ]; then
            echo "You must be on main branch to publish a new version (current branch: $BRANCH))"
            exit 1
        fi
        
        echo "Are you sure you want to publish version $VERSION? (y/N)"
        just _ask-confirm
        flutter pub publish
        open https://pub.dev/packages/hypertrack_plugin/versions/$VERSION
    else
        # removing docs to avoid doc/ folder warning
        rm -rf docs
        echo "Dry run for version $VERSION"
        flutter pub publish --dry-run
        just docs
    fi

setup: get-dependencies

update-sdk-latest wrapper_version commit="true" branch="true":
    #!/usr/bin/env sh
    LATEST_IOS=$(just _latest-ios)
    LATEST_ANDROID=$(just _latest-android)
    just update-sdk {{wrapper_version}} $LATEST_IOS $LATEST_ANDROID {{commit}} {{branch}}

update-sdk-android-latest wrapper_version commit="true" branch="true":
    #!/usr/bin/env sh
    LATEST_ANDROID=$(just _latest-android)
    just update-sdk-android {{wrapper_version}} $LATEST_ANDROID {{commit}} {{branch}}

update-sdk-ios-latest wrapper_version commit="true" branch="true":
    #!/usr/bin/env sh
    LATEST_IOS=$(just _latest-ios)
    just update-sdk-ios {{wrapper_version}} $LATEST_IOS {{commit}} {{branch}}

update-sdk wrapper_version ios_version android_version commit="true" branch="true": build
    #!/usr/bin/env sh
    if [ "{{branch}}" = "true" ] ; then
        git checkout -b update-sdk-ios-{{ios_version}}-android-{{android_version}}
    fi
    just version
    echo "New version is {{wrapper_version}}"
    just _update-wrapper-version-file {{wrapper_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -i {{ios_version}} -a {{android_version}}
    echo "Updating HyperTrack SDK iOS to {{ios_version}}"
    just _update-sdk-ios-version-file {{ios_version}}
    echo "Updating HyperTrack SDK Android to {{android_version}}"
    just _update-sdk-android-version-file {{android_version}}
    just docs
    if [ "{{commit}}" = "true" ] ; then
        git add .
        git commit -m "Update HyperTrack SDK iOS to {{ios_version}} and Android to {{android_version}}"
    fi
    if [ "{{branch}}" = "true" ] && [ "{{commit}}" = "true" ] ; then
        just open-github-prs
    fi

update-sdk-android wrapper_version android_version commit="true" branch="true": build
    #!/usr/bin/env sh
    if [ "{{branch}}" = "true" ] ; then
        git checkout -b update-sdk-android-{{android_version}}
    fi
    just version
    echo "Updating HyperTrack SDK Android to {{android_version}} on {{wrapper_version}}"
    just _update-wrapper-version-file {{wrapper_version}}
    just _update-sdk-android-version-file {{android_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -a {{android_version}}
    just docs
    if [ "{{commit}}" = "true" ] ; then
        git add .
        git commit -m "Update HyperTrack SDK Android to {{android_version}}"
    fi
    if [ "{{branch}}" = "true" ] && [ "{{commit}}" = "true" ] ; then
        just open-github-prs
    fi

update-sdk-ios wrapper_version ios_version commit="true" branch="true": build
    #!/usr/bin/env sh
    if [ "{{branch}}" = "true" ] ; then
        git checkout -b update-sdk-ios-{{ios_version}}
    fi
    just version
    echo "Updating HyperTrack SDK iOS to {{ios_version}} on {{wrapper_version}}"
    just _update-wrapper-version-file {{wrapper_version}}
    just _update-sdk-ios-version-file {{ios_version}}
    ./scripts/update_changelog.sh -w {{wrapper_version}} -i {{ios_version}}
    just docs
    if [ "{{commit}}" = "true" ] ; then
        git add .
        git commit -m "Update HyperTrack SDK iOS to {{ios_version}}"
    fi
    if [ "{{branch}}" = "true" ] && [ "{{commit}}" = "true" ] ; then
        just open-github-prs
    fi

_update-sdk-android-version-file android_version:
    ./scripts/update_file.sh android/build.gradle 'def hyperTrackVersion = \".*\"' 'def hyperTrackVersion = \"{{android_version}}\"'

_update-sdk-ios-version-file ios_version:
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "'HyperTrack', '.*'" "'HyperTrack', '{{ios_version}}'"

_update-wrapper-version-file wrapper_version:
    ./scripts/update_file.sh pubspec.yaml 'version: .*' 'version: {{wrapper_version}}'
    ./scripts/update_file.sh ios/hypertrack_plugin.podspec "s.version             = '.*'" "s.version             = '{{wrapper_version}}'"

version:
    @cat pubspec.yaml | grep version | grep -o -E '{{SEMVER_REGEX}}'
