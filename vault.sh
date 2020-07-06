#!/usr/bin/env bash

# usage() {
#   log_info "usage: $0 [-v] [-h|--help] [--loglevel[=]<value>]" >&2
# }

decrypt-vault() {
  local vault="$1"
  local key="$2"

  cat "${vault}" | nanvault -p "${key}"
}

export-vault-env() {
  local env="${1}"

  log_info "$env"

  while IFS= read -r line; do
    if [[ $line == "$env="* ]]; then
      printf "%s\n" "$line"
    fi
  done

}

export-vault-envs() {
  local vault=$1
  local key=$2
  shift 2

  for env; do
    log_debug $env

    set -o allexport
    source <(decrypt-vault $vault $key | export-vault-env ${env})
    set +o allexport
  done
}

parse-env-string() {
  local -n ref=$1
  local env_string="$2"
  local delimiter="${3:-,}"

  ref=($(echo $env_string | tr "${delimiter}" "\n"))
}

shlibs-vault() {
  optspec=":hv:e:k:-:"
  envs=()

  while getopts "$optspec" optchar; do
    case "${optchar}" in
    -)
      case "${OPTARG}" in
      envs)
        env_string="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      key)
        key="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      vault)
        vault="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      help)
        usage
        exit 2
        ;;
      *)
        catch-unknown-opt "--"
        ;;
      esac
      ;;
    e)
      env_string="${OPTARG}"
      ;;
    k)
      key="${OPTARG}"
      ;;
    v)
      vault="${OPTARG}"
      ;;
    h)
      usage
      exit 2
      ;;
    *)
      catch-unknown-opt "-"
      ;;
    esac
  done

  shift "$((OPTIND - 1))"

  parse-env-string envs $env_string ","

  log_debug "vault '$vault'"
  log_debug "key: '$key'"
  log_debug "envs: '${envs[@]}'"

  log_info "$*"
  log_info

  case "$*" in
  export-envs)
    log_info "Exporting variables"
    export-vault-envs $vault $key ${envs[@]}
    ;;
  view)
    decrypt-vault $vault $key
    ;;
  *)
    usage
    exit 2
    ;;
  esac

}
