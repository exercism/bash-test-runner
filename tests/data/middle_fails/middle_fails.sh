#!/bin/bash

set -o errexit
set -o nounset

main() {
    if [[ $1 == two ]]; then
        echo four
    else
        echo "$1"
    fi
}

main "$@"
