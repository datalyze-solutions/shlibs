#!/usr/bin/env bash

# copy_associative_array() {
#     local source=$1
#     local target=$2

#     eval $(typeset -A -p $source | sed 's/$source=/$target=/')
# }

# copy_array() {
#     local source=$1
#     local target=$2

#     target=("${source[@]}")
# }

clone_associative_array() {
    local source_name="${1}"
    local target_name="${2}"

    declare -n source_ref="$source_name"
    declare -n target_ref="$target_name"

    for k in "${!source_ref[@]}"; do
        # log_debug "$k: ${source_ref[$k]}"
        target_ref[$k]=${source_ref[$k]}
    done

    unset -n source_ref
    unset -n target_ref
}

shlibs.array.sort() {
    local -n -r input_array_ref="$1"
    local -n output_array_ref="$2"

    IFS=$'\n' output_array_ref=($(sort <<<"${input_array_ref[*]}"))
    unset IFS
}