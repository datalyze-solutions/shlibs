#!/usr/bin/env bash

_shlibs-vault-usage() {
  cat <<EOF
shlibs-vault: [parameters] command

Parameters
  -k|--key   <path to the key file>
  -v|--vault <path to the vault file>
  -s|--sep   <seperator for the passed envs, defaults to comma ",">
  -e|--envs  <comma (or --sep) seperated strings of env names to be exported>

Commands
  - export-envs     Exports the passed variables
  - view            Prints the content of the vault

Example
  source /usr/local/bin/shlibs/index.sh
  envs="db_password,master_pwd"
  key="/tmp/key"
  vault="/tmp/secrets.env"
  shlibs-vault --key "$key" --vault "$vault" --envs "${envs}" export-envs
  export | grep db_password
  export | grep master_pwd

EOF
}

decrypt-vault() {
  local vault="$1"
  local key="$2"

  for var in "${vault}" "${key}"; do
    if [ ! -f "${var}" ]; then
      log_error "File does not exist at '${var}'"
      exit 2
    fi
  done

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

  if (( $# == 0 )); then
    log_warn "No ENVS defined to be exported"
    exit 3
  fi

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
  optspec=":hv:e:k:s:-:"
  envs=()
  sep=","

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
      sep)
        sep="${!OPTIND}"
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
    s)
      sep="${OPTARG}"
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

  parse-env-string envs $env_string "${sep:-,}"

  log_debug "vault '$vault'"
  log_debug "key: '$key'"
  log_debug "envs: '${envs[@]}'"
  log_debug "seperator: '$sep'"

  case "$*" in
  export-envs)
    log_info "Exporting variables"
    export-vault-envs $vault $key ${envs[@]}
    ;;
  view)
    decrypt-vault $vault $key
    ;;
  *)
    _shlibs-vault-usage
    exit 2
    ;;
  esac

}
