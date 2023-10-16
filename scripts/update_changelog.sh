#!/bin/bash

while [ "$#" -gt 0 ]; do
    case "$1" in
    -w)
        wrapper_version="$2"
        shift 2
        ;;
    -i)
        ios_version="$2"
        shift 2
        ;;
    -a)
        android_version="$2"
        shift 2
        ;;
    *)
        echo "Usage: $0 [-w wrapper_version] [-i ios_version] [-a android_version]"
        exit 1
        ;;
    esac
done

file="CHANGELOG.md"

if [ ! -f "$file" ]; then
    echo "Error: $file not found."
    exit 1
fi

if [ -z "$wrapper_version" ]; then
    echo "Error: wrapper_version is required."
    exit 1
fi

date=$(date +%Y-%m-%d)

sed -i '' -e "245 i\\
" CHANGELOG.md
sed -i '' -e "245 i\\
[$wrapper_version]: https://github.com/hypertrack/sdk-flutter/releases/tag/$wrapper_version" CHANGELOG.md

sed -i '' -e "6 i\\
" CHANGELOG.md
sed -i '' -e "6 i\\
## [$wrapper_version] - $date" CHANGELOG.md
sed -i '' -e "7 i\\
" CHANGELOG.md
sed -i '' -e "8 i\\
### Changed" CHANGELOG.md
sed -i '' -e "9 i\\
" CHANGELOG.md

if [ -n "$android_version" ]; then
    sed -i '' -e "10 i\\
- Updated HyperTrack SDK Android to $android_version" CHANGELOG.md
fi

if [ -n "$ios_version" ]; then
    sed -i '' -e "10 i\\
- Updated HyperTrack SDK iOS to $ios_version" CHANGELOG.md
fi
