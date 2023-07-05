#!/bin/sh

shlibs.arch() {
    case $(uname --machine) in
    x86_64)
        arch=amd64
        ;;
    arm64|aarch64)
        arch=arm64
        ;;
    ppc64le)
        arch=ppc64le
        ;;
    s390x)
        arch=s390x
        ;;
    *)
        arch=amd64
        ;;
    esac

    echo "${arch}"
}