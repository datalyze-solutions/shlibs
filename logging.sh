#!/bin/sh

logger_tag() {
  local datetime="$(date '+%Y-%m-%d %H:%M:%S.%4N')" # on alpine install coreutils package to get nanoseconds %N
  local app="${0##*/}"
  local level="${1:-info}"
  echo "time=\"$datetime\" level=\"$level\" app=\"$app\" line=\"$LINENO\" msg:"
}

log() {
  local priority=${1:-user.info}  # needs to be logger priority
  local tag="$(logger_tag)"       # name of programm
  shift                           # remove first param from $@
  local msg="$@"                  # all the rest
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
