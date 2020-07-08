#!/usr/bin/env bash

shlibs.os.distribution_id() {
    cat /etc/*release | grep "^ID=" | cut -f 2 -d "="
}
