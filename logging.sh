#!/usr/bin/env bash

_logger_tag_base() {
  echo "time=\"$datetime\" level=\"$level\" app=\"$app\""
}

_logger_tag_info() {
  echo $(_logger_tag_base)
  echo "msg:"
}

_logger_tag_err() {
  echo $(_logger_tag_base)
  echo "file=\"${BASH_SOURCE[$caller_index]}\" line=\"${BASH_LINENO[$caller_index - 1]}\" msg:"
}

_logger_tag_debug() {
  echo $(_logger_tag_base)
  echo "file=\"${BASH_SOURCE[$caller_index]}\" line=\"${BASH_LINENO[$caller_index - 1]}\" function=\"${FUNCNAME[$caller_index]}\" msg:"
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
  local priority=${1:-user.info}      # needs to be logger priority
  local tag="$(logger_tag $priority)" # name of programm
  shift                               # remove first param from $@
  local msg="$@"                      # all the rest
  logger -s -p $priority -t $tag $msg
}

log_debug() {
  log user.debug "$@"
}

log_err() {
  log user.err "$@"
}

log_info() {
  log user.info "$@"
}

log_warn() {
  log user.err "$@"
}

log_notice() {
  log user.notice "$@"
}
