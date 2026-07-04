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

EMSCRIPTEN_SDK_DIR="$HOME/repos/emsdk"

for arg in "$@"; do
    case $arg in
        client|c)    EXE="client"         ;;
        server|s)    EXE="server"         ;;
        wasm|w)      EXE="wasm"           ;;
        run|r)       MODE="run"           ;;
        build|b)     MODE="build"         ;;
        release|rel) BUILD_TYPE="release" ;;
        debug|d)     BUILD_TYPE="debug"   ;;
        tracy|t)     ENABLE_TRACY=true    ;;
    esac
done

if [[ "$EXE" == "client" ]]; then
    SRC_DIR="src/client_desktop/"
elif [[ "$EXE" == "server" ]]; then
    SRC_DIR="src/server/"
    FLAGS+=" -define:SERVER=true"
elif [[ "$EXE" == "wasm" ]]; then
    SRC_DIR="src/client_web/"
    FLAGS+=" -define:IMGUI=false"
    FLAGS+=" -target:js_wasm32 -build-mode:obj -no-entry-point -define:RAYLIB_WASM_LIB=env.o -define:RAYGUI_WASM_LIB=env.o"
fi

OUT_DIR="bin/$BUILD_TYPE/$EXE"
if [[ "$BUILD_TYPE" == "" ]]; then
    OUT_DIR="bin/$EXE"
    if [[ "$EXE" != "wasm" ]]; then
        FLAGS+=" -define:IMGUI=true"
    fi
fi

mkdir -p $OUT_DIR

if [[ "$BUILD_TYPE" == "release" ]]; then
    if [[ "$EXE" != "wasm" ]]; then
        FLAGS+=" -microarch:native"
    fi
    FLAGS+=" -o:speed"
elif [[ "$BUILD_TYPE" == "debug" ]]; then
    FLAGS+=" -debug"
fi

# Build Tracy
if [[ "$ENABLE_TRACY" == true && "$EXE" != "wasm" ]]; then
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
if [[ "$EXE" == "wasm" ]]; then
    export EMSDK_QUIET=1
    [[ -f "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh" ]] && . "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh"

    ODIN_PATH=$(odin root)
    cp $ODIN_PATH/core/sys/wasm/js/odin.js $OUT_DIR

    echo "odin build $SRC_DIR $COLLECTION $FLAGS -out:\"$OUT_DIR/game.wasm.o\""
    odin build $SRC_DIR $COLLECTION $FLAGS -out:"$OUT_DIR/game.wasm.o"

    if [[ $? == 0 ]]; then
        FILES="$OUT_DIR/game.wasm.o ${ODIN_PATH}/vendor/raylib/wasm/libraylib.a ${ODIN_PATH}/vendor/raylib/wasm/libraygui.a ${ODIN_PATH}vendor/box2d/lib/box2d_wasm.o"

        EMCC_FLAGS="-s EXPORTED_RUNTIME_METHODS=['HEAPF32'] -s USE_GLFW=3 -s WASM_BIGINT -s ASSERTIONS=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s ALLOW_MEMORY_GROWTH=1 -s STACK_SIZE=33554432 --shell-file $SRC_DIR/index_template.html"

        # For debugging: Add `-g` to `emcc` (gives better error callstack in chrome)
        emcc -o $OUT_DIR/index.html $FILES $EMCC_FLAGS
        rm $OUT_DIR/game.wasm.o
    fi
else
    if [[ "$MODE" == "run" ]]; then
        # we don't run the executable by `odin run` command because odin doesn't
        # spawn an orphan process and goes away, instead it hogs 400-500mb ram and
        # stays until the executable is done running
        echo "odin build $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR/$EXE"
        odin build $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR/$EXE

        if [[ $? == 0 ]]; then
            echo ./$OUT_DIR/$EXE
            ./$OUT_DIR/$EXE
        fi
    else
        echo "odin $MODE $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR/$EXE"
        odin $MODE $SRC_DIR $COLLECTION $FLAGS -out:$OUT_DIR/$EXE
    fi
fi
