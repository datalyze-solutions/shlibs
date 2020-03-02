#!/usr/bin/env bash

# script="$(readlink --canonicalize-existing "$0")"
# script_dir=$(dirname ${script})

script_dir=$( dirname "${BASH_SOURCE[0]}")
for file in $(find -L ${script_dir} -maxdepth 1 ! -path "${script_dir}/index.sh" -name "*.sh" | sort); do
    source $file
    # echo >&2 "sourced $file"
done