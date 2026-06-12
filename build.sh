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

OUT_DIR="bin/$BUILD_TYPE/$EXE"

if [[ "$EXE" == "client" ]]; then
    SRC_DIR="src/client/"
elif [[ "$EXE" == "server" ]]; then
    SRC_DIR="src/server/"
fi

if [[ "$BUILD_TYPE" == "release" ]]; then
    # FLAGS+="-microarch:native"
    FLAGS+=" -o:speed"
elif [[ "$BUILD_TYPE" == "debug" ]]; then
    FLAGS+=" -debug"
fi

# Build Tracy
if [[ "$ENABLE_TRACY" == true ]]; then
    if [ ! -f "thirdparty/tracy/tracy.so" ]; then
        echo "Building Tracy library"
        (cd "thirdparty/tracy/" && c++ -DTRACY_ENABLE -O2 tracy/public/TracyClient.cpp -shared -fPIC -o tracy.so)
    fi
    FLAGS+=" -define:TRACY_ENABLE=true"
else
    FLAGS+=" -define:TRACY_ENABLE=false"
fi

# collections!
COLLECTION="-collection:src=./src/"
COLLECTION+=" -collection:thirdparty=./thirdparty/"

# RUN ODIN!!
echo "odin $MODE $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR"

odin $MODE $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR
