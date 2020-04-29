#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

rm -drf docs/app/*
rm -drf docs/framework-public/*
rm -drf docs/framework-internal/*

mkdir -p docs/app/img
mkdir -p docs/framework-public/img
mkdir -p docs/framework-internal/img

echo "Creating API Docs for the App"

jazzy   --readme ./src/BlueVanClef/README.md \
        --github_url https://github.com/RiftValleySoftware/BlueVanClef \
        --title BlueVanClef\ Doumentation \
        --min_acl private \
        --output docs/app \
        --theme fullwidth \
        --build-tool-arguments -scheme,"BlueVanClef"
cp ./src/BlueVanClef/img/* docs/app/img

echo "Creating Public API Docs for the Framework"

jazzy   --readme ./src/RVS_BlueThoth/README-PUBLIC.md \
        --github_url https://github.com/RiftValleySoftware/BlueVanClef \
        --title RVS_BlueThoth\ Doumentation \
        --min_acl public \
        --theme fullwidth \
        --exclude ./src/RVS_BlueThoth/src/Implementation/Peripherals/CGA_Bluetooth_Peripheral_Callbacks.swift,./src/RVS_BlueThoth/src/RVS_BlueThoth_Callbacks.swift \
        --output docs/framework-public \
        --build-tool-arguments -scheme,"RVS_BlueThoth_iOS"
cp ./src/RVS_BlueThoth/img/* docs/framework-public/img

echo "Creating Internal API Docs for the Framework"

jazzy   --readme ./src/RVS_BlueThoth/README.md \
        --github_url https://github.com/RiftValleySoftware/BlueVanClef \
        --title RVS_BlueThoth\ Doumentation \
        --min_acl private \
        --theme fullwidth \
        --output docs/framework-internal \
        --build-tool-arguments -scheme,"RVS_BlueThoth_iOS"
cp ./src/RVS_BlueThoth/img/* docs/framework-internal/img

cd "${CWD}"
