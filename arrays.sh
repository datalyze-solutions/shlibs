#!/usr/bin/env bash

copy_associative_array() {
    local source=$1
    local target=$2

    eval $(typeset -A -p $source | sed 's/$source=/$target=/')
}

copy_array() {
    local source=$1
    local target=$2

    target=("${source[@]}")
}
