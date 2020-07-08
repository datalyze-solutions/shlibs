#!/usr/bin/env bash

shlibs.vault.usage() {
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

shlibs.vault.decrypt() {
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

shlibs.vault.export-env() {
  local env="${1}"

  log_debug "$env"

  while IFS= read -r line; do
    if [[ $line == "$env="* ]]; then
      printf "%s\n" "$line"
    fi
  done

}

shlibs.vault.export-envs() {
  local vault=$1
  local key=$2
  shift 2

  if (($# > 0)); then
    for env; do
      log_debug $env

      # set -o allexport
      export $(shlibs.vault.decrypt $vault $key | shlibs.vault.export-env ${env})
      # set +o allexport
    done
  else
    log_warn "No ENVS defined to be exported"
  fi
}

shlibs.vault.parse-env-string() {
  local -n ref=$1
  local env_string="$2"
  local delimiter="${3:-,}"

  ref=($(echo $env_string | tr "${delimiter}" "\n"))
}

shlibs.vault() {

  local OPTIND ignore
  local OPTARG

  _optspec=":hv:e:k:s:-:"
  _envs=()
  _sep=","

  log_debug "vault '$_vault'"
  log_debug "key: '$_key'"
  log_debug "env-string: '${_env_string}'"
  log_debug "seperator: '$_sep'"

  while getopts "$_optspec" optchar; do
    case "${optchar}" in
    -)
      case "${OPTARG}" in
      envs)
        _env_string="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      key)
        _key="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      sep)
        _sep="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      vault)
        _vault="${!OPTIND}"
        OPTIND=$(($OPTIND + 1))
        ;;
      help)
        _shlibs-vault-usage
        ;;
      *)
        shlibs.getopts.catch-unknown-opt "--"
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
      _shlibs-vault-usage
      ;;
    *)
      shlibs.getopts.catch-unknown-opt "-"
      ;;
    esac
  done

  shift "$((OPTIND - 1))"

  case "$*" in
  export-envs)
    log_debug "vault '$_vault'"
    log_debug "key: '$_key'"
    log_debug "env-string: '${_env_string}'"
    log_debug "seperator: '$_sep'"

    shlibs.vault.parse-env-string _envs $_env_string "${_sep:-,}"

    log_debug "parsed envs: '${_envs[@]}'"

    log_info "Exporting variables: ${_envs[@]}"
    shlibs.vault.export-envs $_vault $_key ${_envs[@]}
    ;;
  view)
    shlibs.vault.decrypt $_vault $_key
    ;;
  *)
    shlibs.vault.usage
    ;;
  esac

  unset _env_string
  unset _vault
  unset _key
  unset _envs
  unset OPTIND
  unset OPTARG
}
