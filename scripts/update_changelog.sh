#!/bin/bash

# Check if params are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <wrapper_version> <ios_version> <android_version>"
    exit 1
fi

wrapper_version="$1"
ios_version="$2"
android_version="$3"

file="CHANGELOG.md"

if [ ! -f "$file" ]; then
    echo "Error: $file not found."
    exit 1
fi

date="2023-10-02"

output="## [$wrapper_version] - $date

### Changed\n"

if [ $ios_version -ne "" ]; then
    date=date:"- Updated HyperTrack SDK iOS to $ios_version"
fi

if [ $android_version -ne "" ]; then
    date=date:"- Updated HyperTrack SDK Android to $android_version"
fi

# cat $file | sed "6i/$output" >tmp
# cat tmp >$file
# rm -f tmp

echo "Updated CHANGELOG with \n\n$output"
