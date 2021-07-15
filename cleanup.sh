#!/bin/sh

set -eo pipefail

starting_directory=$(pwd)
doltdb="${GITHUB_WORKSPACE}/doltdb"

_main() {
    _cleanup
}

_cleanup() {
    rm -rf "${doltdb}"
}

_main
