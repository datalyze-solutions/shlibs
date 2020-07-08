#!/usr/bin/env bash

shlibs.os.distribution_id() {
    cat /etc/*release | grep "^ID=" | cut -f 2 -d "="
}

shlibs.os.type() {
    echo "${OSTYPE:-unkown}"
}

shlibs.os.type.base() {
    shlibs.os.type | cut -f 1 -d "-"
}