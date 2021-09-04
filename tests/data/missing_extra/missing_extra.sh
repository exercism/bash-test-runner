#!/bin/bash

set -o errexit
set -o nounset

main() {
    echo "$1"
}

main "$@"
