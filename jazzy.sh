#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs/*

echo "Creating API Docs for the App"

jazzy   --readme ./README.md \
        --github_url https://github.com/LittleGreenViper/ClassicalGas \
        --title ClassicalGas\ Doumentation \
        --min_acl public \
        --build-tool-arguments -scheme,"ClassicalGas"
cp icon.png docs/icon.png

cd "${CWD}"
