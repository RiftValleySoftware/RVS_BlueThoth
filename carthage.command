#!/bin/sh
if command -v carthage; then
    CWD="$(pwd)"
    MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
    cd "${MY_SCRIPT_PATH}"
    carthage update --no-build --new-resolver
    cd "${CWD}"
else
    echo "\nERROR: Carthage is Not Installed.\n\nTo install Carthage, make sure that you have Homebrew installed, then run:\n"
    echo "brew install carthage\n"
fi
