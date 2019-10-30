#!/bin/bash

set -o errexit
set -o nounset

main() {
    if [[ $1 == three ]]; then
        echo four
    else
        echo "$1"
    fi
}

main "$@"
