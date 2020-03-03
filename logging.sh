#!/usr/bin/env bash

_logger_tag_base() {
  echo "time=\"$datetime\" level=\"$level\" app=\"$app\""
}

_logger_tag_info() {
  echo $(_logger_tag_base)
  # echo "msg:"
}

_logger_tag_err() {
  echo $(_logger_tag_base)
  echo "file=\"${BASH_SOURCE[$caller_index]}\" line=\"${BASH_LINENO[$caller_index - 1]}\""
}

_logger_tag_debug() {
  echo $(_logger_tag_base)
  echo "file=\"${BASH_SOURCE[$caller_index]}\" line=\"${BASH_LINENO[$caller_index - 1]}\" function=\"${FUNCNAME[$caller_index]}\""
}

logger_tag() {
  local datetime="$(date '+%Y-%m-%d %H:%M:%S.%4N')" # on alpine install coreutils package to get nanoseconds %N
  local app="${0##*/}"
  local level="${1:-user.info}"

  # take care to adjust the index appropriate to caller stack depth
  local caller_index=4

  # https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
  # line numbers are stored in the array BASH_LINENO -> "${BASH_LINENO[*]}"
  # called function in calling order: FUNCNAME -> "${FUNCNAME[*]}"
  #  echo "function=\"${FUNCNAME[$caller_index]}\""
  #  echo "functions=\"${FUNCNAME[*]}\""
  #  echo "lines=\"${BASH_LINENO[*]}\""

  case "$level" in
  user.info)
    echo $(_logger_tag_info)
    ;;
  user.debug)
    echo $(_logger_tag_debug)
    ;;
  user.err)
    echo $(_logger_tag_err)
    ;;
  user.warn)
    echo $(_logger_tag_info)
    ;;
  user.notice)
    echo "time=\"$datetime\""
    ;;
  *)
    echo $(_logger_tag_info)
    ;;
  esac

}

log() {
  # https://eklitzke.org/using-local-optind-with-bash-getopts
  local OPTIND ignore
  local invalid_opts=0
  local quiet=0

  while getopts ":p:q" opt; do
    case $opt in
    q)
      quiet=$((quiet + 1))
      # quiet=1
      ;;
    p)
      # needs to be logger priority
      priority="${OPTARG:-user.info}"
      ;;
    \?)
      # count invalid options, e.g. log_info "-d test test"
      # use them as message
      invalid_opts=$((invalid_opts + 1))
      ;;
    esac
  done
  # remove opts from msg; take invalid opts into calculation
  shift "$((OPTIND - 1 - invalid_opts))"

  local tag="$(logger_tag $priority)"   # name of programm
  local msg="$@"                        # use all the rest as message

  if [ "${quiet:-0}" -eq 0 ]; then
    logger -s -p $priority "$tag msg=\"$msg\""
  else
    if [ "${quiet:-0}" -eq 1 ]; then
      echo >&2 "[$priority] $msg"
    else
      echo >&2 "$msg"
    fi
  fi
}

log_debug() {
  log -p user.debug "$@"
}

log_err() {
  log -p user.err "$@"
}

log_info() {
  log -p user.info "$@"
}

log_warn() {
  log -p user.err "$@"
}

log_notice() {
  log -p user.notice "$@"
}
