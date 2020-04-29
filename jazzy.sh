#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs/*

echo "Creating API Docs for the App"

jazzy   --readme ./README.md \
        --github_url https://github.com/RiftValleySoftware/BlueVanClef \
        --title BlueVanClef\ Doumentation \
        --min_acl private \
        --output docs/app \
        --theme fullwidth \
        --build-tool-arguments -scheme,"BlueVanClef"
cp icon.png docs/app/icon.png
cp img/* docs/app/img

echo "Creating Public API Docs for the Framework"

jazzy   --readme ./src/RVS_BlueThoth/README.md \
        --github_url https://github.com/RiftValleySoftware/BlueVanClef \
        --title RVS_BlueThoth\ Doumentation \
        --min_acl public \
        --theme fullwidth \
        --exclude ./src/RVS_BlueThoth/src/Implementation/Peripherals/CGA_Bluetooth_Peripheral_Callbacks.swift \
        --output docs/framework \
        --build-tool-arguments -scheme,"RVS_BlueThoth_iOS"
cp icon.png docs/framework/icon.png
cp img/* docs/framework/img

cd "${CWD}"
