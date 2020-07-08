#!/usr/bin/env bash

shlibs.getopts.catch-unknown-opt() {
  local cmd_signs="${1:---}"

  if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" = ":" ]; then
    echo "Unknown option ${cmd_signs}${OPTARG}" >&2
  fi
}