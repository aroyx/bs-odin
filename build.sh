#!/bin/bash

# Usage: 
# `./build.sh` - run the client
#
# `./build.sh client run release` (or `./build.sh c r r`)
# `./build.sh server build debug` (or `./build.sh s b d`)
#
# Heads up: "release" takes time to build due to `-o:speed`. In my device it it 5x slower.

## Executable (client/server)
SRC_DIR="src/client/"
EXE_NAME="client"
 
if [[ "$1" == "client" || "$1" == "c" ]]; then
    SRC_DIR="src/client/"
    EXE_NAME="client"
elif [[ "$1" == "server" || "$1" == "s" ]]; then
    SRC_DIR="src/server/"
    EXE_NAME="server"
else
    echo "No executable selected. Selecting 'client' (or 'c') by default"
    echo "Options: "
    echo "\t 'client' (or 'c')"
    echo "\t 'server' (or 's')"
fi

shift

## Action
MODE="run"

if [[ "$1" == "run" || "$1" == "r" ]]; then
    MODE="run"
elif [[ "$1" == "build" || "$1" == "b" ]]; then
    MODE="build"
else
    echo "No action selected. Selecting 'run' (or 'r') by default"
    echo "Options: "
    echo "\t 'run' (or 'r')"
    echo "\t 'build' (or 'b')"
fi

shift

## Build type
FLAGS="-show-timings"
OUT_DIR="bin/" # no output when running

if [[ "$1" == "release" || "$1" == "r" ]]; then
    # FLAGS+="-microarch:native"
    FLAGS+=" -o:speed"
    OUT_DIR+="release/"
elif [[ "$1" == "debug" || "$1" == "d" ]]; then
    FLAGS+=" -debug"
    OUT_DIR+="debug/"
else
    echo "No build type selected. Selecting 'release' (or 'r') by default"
    echo "Options: "
    echo "\t 'release' (or 'r')"
    echo "\t 'debug' (or 'd')"
fi

OUT_DIR+="bs-odin" # debug/bs-odin or release/bs-odin

shift

# Build Tracy
ENABLE_TRACY=true

if [[ "$ENABLE_TRACY" == true ]]; then
    if [ ! -f "thirdparty/tracy/tracy.so" ]; then
        echo "Building Tracy library"
        (cd "thirdparty/tracy/" && c++ -DTRACY_ENABLE -O2 tracy/public/TracyClient.cpp -shared -fPIC -o tracy.so)
    else
        echo "Tracy Already Built"
    fi
    FLAGS+=" -define:TRACY_ENABLE=true"
else
    FLAGS+=" -define:TRACY_ENABLE=false"
fi

# collections!
COLLECTION="-collection:src=./src/"
COLLECTION+=" -collection:thirdparty=./thirdparty/"

# RUN ODIN!!
echo "odin $MODE src/client/ $COLLECTION $FLAGS -out:$OUT_DIR"

odin $MODE src/client/ $COLLECTION $FLAGS -out:$OUT_DIR
