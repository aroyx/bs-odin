#!/bin/bash

# Usage: 
# `./hmh.sh` - run the proj
#
# `./hmh.sh run` - run (same as `./hmh.sh`)
# `./hmh.sh run release` - run in release mode
# `./hmh.sh run debug` - run in debug mode
#
# `./hmh.sh build` - build (files are inside bin dir)
# `./hmh.sh build release` - build in release mode
# `./hmh.sh build debug` - build in debug mode
#
# `Alternatively shortcuts can be used - run (r), build (b), debug (d), release (r), 
# `./hmh.sh r r` - run in release
# `./hmh.sh b d` - build in debug
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

odin $MODE src/ -collection:src=src $FLAGS -out:$OUT_DIR
