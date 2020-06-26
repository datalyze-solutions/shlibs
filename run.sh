#!/bin/sh

run_if_exists() {
  local script="$1"
  if [ -f "$script" ]; then
    "$script"
  fi
}