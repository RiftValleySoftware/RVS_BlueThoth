#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs
jazzy   --github_url https://github.com/RiftValleySoftware/RVS_PersistentPrefs\
        --readme ./README.md \
        --theme fullwidth \
        --author The\ Great\ Rift\ Valley\ Software\ Company \
        --author_url https://riftvalleysoftware.com \
        --module RVS_Persistent_Prefs \
        --min-acl private
cp icon.png docs/icon.png
cd "${CWD}"
