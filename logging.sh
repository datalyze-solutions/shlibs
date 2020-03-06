#!/usr/bin/env bash

declare -A LOGGING_LEVELS=([DEBUG]=0 [debug]=0 [INFO]=1 [info]=1 [WARN]=2 [warn]=2 [WARNING]=2 [warning]=2 [ERR]=3 [err]=3 [ERROR]=3 [error]=3)

_stats_base() {
  echo "time=\"$datetime\" level=\"$level\" app=\"$app\""
}

_stats_info() {
  echo $(_stats_base)
  # echo "msg:"
}

_stats_err() {
  echo $(_stats_base)
  echo "file=\"${BASH_SOURCE[$caller_index]}\" line=\"${BASH_LINENO[$caller_index - 1]}\""
}

_stats_debug() {
  echo $(_stats_base)
  echo "file=\"${BASH_SOURCE[$caller_index]}\" line=\"${BASH_LINENO[$caller_index - 1]}\" function=\"${FUNCNAME[$caller_index]}\""
}

get_stats() {
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
    echo $(_stats_info)
    ;;
  user.debug)
    echo $(_stats_debug)
    ;;
  user.err)
    echo $(_stats_err)
    ;;
  user.warn)
    echo $(_stats_info)
    ;;
  user.notice)
    echo "time=\"$datetime\""
    ;;
  *)
    echo $(_stats_info)
    ;;
  esac

}

count_params() {
  local optarg_value="$1"
  # in case of paramless value, OPTARG will be the next parameter with leading '-' char
  if [ "${optarg_value:0:1}" = "-" ]; then
    echo 1
  else
    echo 2
  fi
}

_log_usage() {
  local function_name="${FUNCNAME[-1]:-log}"
  cat <<EOF
Usage:
    ${function_name:-log} [OPTIONS] [message(s)]

    Enhanced 'echo' to log messages with extra infos

Options
    -h, --help              show's usage information
    -M, --mode              the programm to use: 'echo' or 'logger'
    -X, --no-stats          excludes statistics, e.g. time, line, function, etc.
    -p, --priority          logger priority
    -L, --level             level in the LOGGING_LEVELS array
                            Setting the global variable LOGGING_LEVEL, you can specify if a message should be displayed.
                            e.g. LOGGING_LEVEL=err -> only the highest logging function will display anything
                            Levels:
                              * level 0: DEBUG, debug
                              * level 1: INFO, info
                              * level 2: WARN, WARNING, warn, warning
                              * level 3: ERR, ERROR, err, error
EOF
}

log() {

  # translate long options to short
  args=
  for arg; do
    delim=""
    case "$arg" in
    --help) args="${args}-h " ;;
    --mode) args="${args}-M " ;;
    --priority) args="${args}-p " ;;
    --level) args="${args}-L " ;;
    --no-stats) args="${args}-X " ;;
    # pass through anything else
    *)
      [[ "${arg:0:1}" == "-" ]] || delim="\""
      args="${args}${delim}${arg}${delim} "
      ;;
    esac
  done
  # reset the translated args
  eval set -- $args

  # https://eklitzke.org/using-local-optind-with-bash-getopts
  local OPTIND ignore
  local invalid_opts=0
  local valid_opts=0
  local local_logging_level=0
  local global_logging_level="${LOGGING_LEVEL:-DEBUG}"

  local mode="logger"
  local show_stats=1

  while getopts ":hM:Xp:L:" opt; do
    case $opt in
    L)
      params=$(count_params "${OPTARG}")
      valid_opts=$((valid_opts + params))
      local_logging_level="${OPTARG}"
      ;;
    M)
      params=$(count_params "${OPTARG}")
      valid_opts=$((valid_opts + params))
      if [ "${OPTARG}" = "logger" ] || [ "${OPTARG}" = "echo" ]; then
        mode="${OPTARG}"
      fi
      ;;
    p)
      params=$(count_params "${OPTARG}")
      valid_opts=$((valid_opts + params))
      # needs to be logger priority
      priority="${OPTARG:-user.info}"
      ;;
    X)
      show_stats=0
      valid_opts=$((valid_opts + 1))
      ;;
    h)
      _log_usage
      return
      ;;
    *)
      # echo "invalid option * $OPTARG"
      # count invalid options, e.g. log_info "-d test test"
      # use them as message
      invalid_opts=$((invalid_opts + 1))
      ;;
    esac
  done
  # shift "$((OPTIND - 1))"
  shift "$valid_opts"

  local stats="$(get_stats $priority)" # name of programm
  local msg="$@"                       # use all the rest as message

  # check, if we should print messages, depending on global logging level order
  if ((${LOGGING_LEVELS[$global_logging_level]:-0} > local_logging_level)); then
    return
  fi

  case $mode in
  logger)
    if [ "${show_stats}" -eq 1 ]; then
      logger -s -p $priority "$stats msg=\"$msg\""
    else
      logger -s -p $priority "msg=\"$msg\""
    fi
    ;;
  echo)
    if [ "${show_stats}" -eq 1 ]; then
      echo >&2 "[$priority - $stats] $msg"
    else
      echo >&2 "$msg"
    fi
    ;;
  *)
    logger -s -p $priority "$stats msg=\"$msg\""
    ;;
  esac
}

# level 0
log_debug() {
  log --level 0 --priority user.debug "$@"
}

# level 1
log_info() {
  log --level 1 --priority user.info "$@"
}

log_warn() {
  log --level 2 --priority user.warn "$@"
}
log_warning() {
  log --level 2 --priority user.warn "$@"
}

log_err() {
  log --level 3 --priority user.err "$@"
}
log_error() {
  log --level 3 --priority user.err "$@"
}

# show always
log_notice() {
  log --level 4 --priority user.notice "$@"
}
