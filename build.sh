#!/bin/bash

# Usage: 
# `./build.sh` - run the client
#
# `./build.sh client run release tracy` (or `./build.sh c r rel t`)
# `./build.sh server build debug` (or `./build.sh s b d`)
#
# Heads up: "release" takes time to build due to `-o:speed`. In my device it it 5x slower.

## Defaults
EXE="client"
MODE="run"
FLAGS="-show-timings"
ENABLE_TRACY=false
BUILD_TYPE="" # no need for super fast release
SRC_DIR="src/"

for arg in "$@"; do
    case $arg in
        client|c)    EXE="client" ;;
        server|s)    EXE="server" ;;
        run|r)       MODE="run" ;;
        build|b)     MODE="build" ;;
        release|rel) BUILD_TYPE="release" ;;
        debug|d)     BUILD_TYPE="debug" ;;
        tracy|t)     ENABLE_TRACY=true ;;
    esac
done

if [[ "$EXE" == "server" ]]; then
    FLAGS+=" -define:SERVER=true"
fi

OUT_DIR="bin/$BUILD_TYPE/$EXE"

if [[ "$BUILD_TYPE" == "release" ]]; then
    # FLAGS+="-microarch:native"
    FLAGS+=" -o:speed"
elif [[ "$BUILD_TYPE" == "debug" ]]; then
    FLAGS+=" -debug"
else
    OUT_DIR="bin/$EXE"
fi

# Build Tracy
if [[ "$ENABLE_TRACY" == true ]]; then
    if [[ ! -f "thirdparty/tracy/tracy.so" ]]; then
        echo "Building Tracy library"
        (cd "thirdparty/tracy/" && c++ -DTRACY_ENABLE -O2 tracy/public/TracyClient.cpp -shared -fPIC -o tracy.so)
    fi
    FLAGS+=" -define:TRACY_ENABLE=true"
else
    FLAGS+=" -define:TRACY_ENABLE=false"
fi

# collections!
COLLECTION+=" -collection:thirdparty=./thirdparty/"

# RUN ODIN!!
if [[ "$MODE" == "run" ]]; then
    # we don't run the executable by `odin run` command because odin doesn't
    # spawn an orphan process and goes away, instead it hogs 400-500mb ram and
    # stays until the executable is done running
    echo "odin build $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR"
    odin build $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR

    if [[ $? == 0 ]]; then
        echo ./$OUT_DIR
        ./$OUT_DIR
    fi
else
    echo "odin $MODE $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR"
    odin $MODE $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR
fi
