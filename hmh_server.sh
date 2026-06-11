#!/bin/bash

# Usage: 
# `./hmh_server.sh` - run the proj
#
# `./hmh_server.sh run` - run (same as `./hmh.sh`)
# `./hmh_server.sh run release` - run in release mode
# `./hmh_server.sh run debug` - run in debug mode
#
# `./hmh_server.sh build` - build (files are inside bin dir)
# `./hmh_server.sh build release` - build in release mode
# `./hmh_server.sh build debug` - build in debug mode
#
# `Alternatively shortcuts can be used - run (r), build (b), debug (d), release (r), 
# `./hmh_server.sh r r` - run in release
# `./hmh_server.sh b d` - build in debug
#
# Heads up: "release" takes time to build due to `-o:speed`. In my device it it 5x slower.

MODE="run"
FLAGS="-show-timings"
OUT_DIR="bin/" # no output when running

if [[ "$1" == "run" || "$1" == "r" ]]; then
    MODE="run"
elif [[ "$1" == "build" || "$1" == "b" ]]; then
    MODE="build"
fi

if [[ "$2" == "release" || "$2" == "r" ]]; then
    # FLAGS+="-microarch:native"
    FLAGS+=" -o:speed"
    OUT_DIR+="release/"
elif [[ "$2" == "debug" || "$2" == "d" ]]; then
    FLAGS+=" -debug"
    OUT_DIR+="debug/"
fi

OUT_DIR+="hmh"

# Build Tracy
if [ ! -f "thirdparty/tracy/tracy.so" ]; then
    echo "Building Tracy library"
    (cd "thirdparty/tracy/" && c++ -DTRACY_ENABLE -O2 tracy/public/TracyClient.cpp -shared -fPIC -o tracy.so)
else
    echo "Tracy Already Built"
fi

COLLECTION="-collection:src=./src/"
COLLECTION+=" -collection:thirdparty=./thirdparty/"

odin $MODE src/server/ $COLLECTION $FLAGS -out:$OUT_DIR
