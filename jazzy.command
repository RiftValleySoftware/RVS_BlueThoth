#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

rm -drf docs/framework-public/*
rm -drf docs/framework-internal/*

mkdir -p docs/framework-public/img
mkdir -p docs/framework-internal/img

echo "Creating Public API Docs for the iOS Framework\n"

jazzy   --readme ./Sources/RVS_BlueThoth/README-PUBLIC.md \
        --github_url https://github.com/RiftValleySoftware/RVS_BlueThoth \
        --title RVS_BlueThoth\ Doumentation \
        --min_acl public \
        --theme fullwidth \
        --exclude ./Sources/RVS_BlueThoth/Implementation/Peripherals/CGA_Bluetooth_Peripheral_Callbacks.swift,./Sources/RVS_BlueThoth/RVS_BlueThoth_Callbacks.swift \
        --output docs/framework-public \
        --build-tool-arguments -scheme,"RVS_BlueThoth"
cp ./Sources/RVS_BlueThoth/RVS_BlueThoth.docc/Resources/* docs/framework-public/img
cp ./icon.png docs/framework-public/icon.png

echo "\nCreating Internal API Docs for the iOS Framework\n"

jazzy   --readme ./README.md \
        --github_url https://github.com/RiftValleySoftware/RVS_BlueThoth/ \
        --title RVS_BlueThoth\ Doumentation \
        --min_acl private \
        --theme fullwidth \
        --output docs/framework-internal \
        --build-tool-arguments -scheme,"RVS_BlueThoth"
cp ./Sources/RVS_BlueThoth/RVS_BlueThoth.docc/Resources/* docs/framework-internal/img
cp ./icon.png docs/framework-internal/icon.png

cd "${CWD}"
