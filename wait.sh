#!/bin/sh

shlibs.wait_indefinitely() {
    while true; do
        tail -f /dev/null &
        wait "${!}"
    done
}

shlibs.wait_for_postgres() {
    local host="${1:-127.0.0.1}"
    local sleeptime="${2:-5}"
    local user="${3:-root}"

    log_info "Checking for postgres..."
    until pg_isready -U $user -q -h $host; do
        log_err "Postgres is unavailable - retrying $host in a $sleeptime seconds"
        sleep $sleeptime
    done
    log_info "Postgres is available"
}

wait_indefinitely() {
    shlibs.wait_indefinitely "$@"
}

wait_for_postgres() {
    shlibs.wait_for_postgres "$@"
}