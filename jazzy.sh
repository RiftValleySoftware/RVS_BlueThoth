#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"

rm -drf docs/framework-public/*
rm -drf docs/framework-internal/*

mkdir -p docs/framework-public/img
mkdir -p docs/framework-internal/img

echo "Creating Public API Docs for the Framework\n"

jazzy   --readme ./src/RVS_BlueThoth/README-PUBLIC.md \
        --github_url https://github.com/RiftValleySoftware/RVS_BlueThoth \
        --title RVS_BlueThoth\ Doumentation \
        --min_acl public \
        --theme fullwidth \
        --exclude ./src/Source/Implementation/Peripherals/CGA_Bluetooth_Peripheral_Callbacks.swift,./src/Source/RVS_BlueThoth_Callbacks.swift \
        --output docs/framework-public \
        --build-tool-arguments -scheme,"RVS_BlueThoth_iOS"
cp ./img/* docs/framework-public/img

echo "\nCreating Internal API Docs for the Framework\n"

jazzy   --readme ./README.md \
        --github_url https://github.com/RiftValleySoftware/BlueVanClef \
        --title RVS_BlueThoth\ Doumentation \
        --min_acl private \
        --theme fullwidth \
        --output docs/framework-internal \
        --build-tool-arguments -scheme,"RVS_BlueThoth_iOS"
cp ./img/* docs/framework-internal/img

cd "${CWD}"
