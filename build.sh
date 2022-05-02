#!/bin/bash

set -e

if [ -z $1 ]; then
    echo "Please specify wasmedge path"
else
    WASMEDGE=$1
    WASI_NN_DIR=$(dirname "$0" | xargs dirname)
    WASI_NN_DIR=$(realpath $WASI_NN_DIR)
    WASMEDGE=$(realpath $WASMEDGE)
    source /opt/intel/openvino_2021/bin/setupvars.sh

    FIXTURE=https://github.com/intel/openvino-rs/raw/main/crates/openvino/tests/fixtures/mobilenet
    pushd $WASI_NN_DIR/rust/
    cargo build --release --target=wasm32-wasi
    mkdir -p $WASI_NN_DIR/rust/examples/classification-example/build
    RUST_BUILD_DIR=$(realpath $WASI_NN_DIR/rust/examples/classification-example/build/)
    cp -rn images $RUST_BUILD_DIR
    pushd examples/classification-example
    cargo build --release --target=wasm32-wasi
    cp target/wasm32-wasi/release/wasi-nn-example.wasm $RUST_BUILD_DIR
    pushd build

    if [ ! -f $RUST_BUILD_DIR/mobilenet.bin ]; then
        wget --no-clobber --directory-prefix=$RUST_BUILD_DIR $FIXTURE/mobilenet.bin
    fi
    if [ ! -f $RUST_BUILD_DIR/mobilenet.xml ]; then
        wget --no-clobber --directory-prefix=$RUST_BUILD_DIR $FIXTURE/mobilenet.xml
    fi
    if [ ! -f $RUST_BUILD_DIR/tensor.bgr ]; then
        wget --no-clobber $FIXTURE/tensor-1x224x224x3-f32.bgr --output-document=$RUST_BUILD_DIR/tensor.bgr
    fi
    # Manually run .wasm
    echo "Running example with WasmEdge ${WASMEDGE}"
    $WASMEDGE --dir fixture:$RUST_BUILD_DIR --dir .:. wasi-nn-example.wasm
    # valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose /root/WasmEdge/build/tools/wasmedge/wasmedge --dir fixture:$RUST_BUILD_DIR wasi-nn-example.wasm
    # /root/wasmtime/target/debug/wasmtime run --mapdir fixture::$RUST_BUILD_DIR wasi-nn-example.wasm --wasi-modules=experimental-wasi-nn
fi
