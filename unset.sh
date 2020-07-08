#!/usr/bin/env bash

# unset namespaced shlibs functions
for F in $(declare -F | grep -e shlibs | cut -f 3 -d " "); do
  # echo >&2 "unset $F"
  unset -f $F
done

# unset all other functions
for file in $(find -L ${script_dir} -maxdepth 1 ! -path "${script_dir}/index.sh" ! -path "${script_dir}/unset.sh" -name "*.sh" | sort); do
  functions=$(grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' $file | cut -f 1 -d "(")
  for F in ${functions[@]}; do
    # echo >&2 "unset $F"
    unset -f $F
  done
done
