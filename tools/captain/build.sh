#!/bin/bash -e

##
# Pre-requirements:
# - env FUZZER: fuzzer name (from fuzzers/)
# - env TARGET: target name (from targets/)
# + env MAGMA: path to magma root (default: ../../)
# + env FORCE: if set, force build even if image exists (default: 0)
# + env ISAN: if set, build the benchmark with ISAN/fatal canaries (default:
#       unset)
# + env HARDEN: if set, build the benchmark with hardened canaries (default:
#       unset)
##

if [ -z $FUZZER ] || [ -z $TARGET ]; then
    echo '$FUZZER and $TARGET must be specified as environment variables.'
    exit 1
fi
IMG_NAME="magma/$FUZZER/$TARGET"
MAGMA=${MAGMA:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" >/dev/null 2>&1 \
    && pwd)"}
source "$MAGMA/tools/captain/common.sh"

if [ ! -z $ISAN ]; then
    isan_flag="--build-arg isan=1"
fi
if [ ! -z $HARDEN ]; then
    harden_flag="--build-arg harden=1"
fi

if [ -z $(docker image ls -q "$IMG_NAME") ] || [ ! -z $FORCE ]; then
    docker build -t "$IMG_NAME" \
        --build-arg fuzzer_name="$FUZZER" \
        --build-arg target_name="$TARGET" \
        --build-arg USER_ID=$(id -u $USER) \
        --build-arg GROUP_ID=$(id -g $USER) \
        $isan_flag $harden_flag \
        -f "$MAGMA/docker/Dockerfile" "$MAGMA"
fi

echo "$IMG_NAME"