#!/usr/bin/env bash

shlibs.run-init-scripts() {

  local OPTIND ignore
  local OPTARG

  local init_script_dirs="/opt/init"
  local _optspec=":hs:-:"

  while getopts "$_optspec" optchar; do
    case "${optchar}" in
    -)
      case "${OPTARG}" in
      init_script_dirs)
        init_script_dirs="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      *)
        shlibs.getopts.catch-unknown-opt "--"
        ;;
      esac
      ;;
    s)
      init_script_dirs="${OPTARG}"
      ;;
    *)
      shlibs.getopts.catch-unknown-opt "-"
      ;;
    esac
  done

  shift "$((OPTIND - 1))"

  log_debug "$init_script_dirs"
  log_debug "$@"

  IFS=':' read -ra init_scripts <<<"$init_script_dirs"
  log_debug "init_scripts: ${init_scripts[@]}"

  for search_string in "$@"; do
    for search_path in ${init_scripts[@]}; do
      log_debug "USING $search_path ${search_string}"
      found_init_files=($(find -L "${search_path}" -type f -name "$search_string" | sort))
      # compose arrays, like spread operator
      init_files=("${init_files[@]}" "${found_init_files[@]}")
      log_debug "found init files: ${found_init_files[@]}"
      log_debug "init_files: ${init_files[@]}"
    done
  done

  shlibs.array.sort.unique init_files init_files
  log_debug "init_files: ${init_files[@]}"

  for init_file in ${init_files[@]}; do
    log_info "Running init script '$init_file'"
    bash $init_file
  done

  # clean vars, if we run the command again in the same shell, the are still set otherwise
  unset init_files
}
