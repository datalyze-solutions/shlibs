#!/usr/bin/env bash

shlibs.run-init-scripts() {

  _find_init_files() {
    local search_path="${1:-${INIT_SCRIPT_DIR}}"
    local search_string="${2:-}"
    shift 2

    find -L "${search_path}" -type f -name "$search_string" "$@" | sort
  }

  for search_string in "$@"; do
    # remove path -printf '%f\n'
    for search_path in ${INIT_SCRIPT_DIR} ${INIT_LANGUAGE_SCRIPT_DIR}; do
      found_init_files=($(_find_init_files ${search_path} ${search_string:-*.sh}))
      init_files=("${init_files[@]}" "${found_init_files[@]}")
    done
  done

  # for arg in "$@"; do
  #   case "$*" in
  #   *--init* | *-i*)
  #     init_files=($(_find_init_files -name "*.sh" ! -name "*.production.sh" ! -name "*.development.sh"))
  #     log_debug "init_files: ${init_files[@]}"
  #     ;;
  #   *--development* | *--dev* | *-d*)
  #     init_files_development=($(_find_init_files -name "*.development.sh"))
  #     log_debug "init_files_development: ${init_files_development[@]}"
  #     ;;
  #   *--production* | *--prod* | *-p*)
  #     init_files_production=($(_find_init_files -name "*.production.sh"))
  #     log_debug "init_files_production: ${init_files_production[@]}"
  #     ;;
  #   *--user* | *-u*)
  #     init_files_user=($(_find_init_files -name "*.user.sh"))
  #     log_debug "init_files_user: ${init_files_production[@]}"
  #     ;;
  #   esac
  # done

  # compose arrays, like spread operator
  # init_files=("${init_files[@]}" "${init_files_development[@]}" "${init_files_production[@]}" "${init_files_user[@]}")

  shlibs.array.sort.unique init_files init_files
  log_debug "init_files: ${init_files[@]}"

  for init_file in ${init_files[@]}; do
    log_info "Running init script '$init_file'"
    bash $init_file
  done

  # clean vars, if we run the command again in the same shell, the are still set otherwise
  unset -f _find_init_files
  unset init_files
}
