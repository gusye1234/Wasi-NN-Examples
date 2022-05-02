rustup target add wasm32-wasi
rustup target add wasm32-unknown-unknown

source /opt/intel/openvino_2021/bin/setupvars.sh
ldconfig

echo $(pwd)
echo $(ls)
echo $(ls ./WasmEdge)
echo $(ls ./WasmEdge/build)
echo $(ls ./WasmEdge/build/tools)
echo $(ls ./WasmEdge/build/tools/wasmedge)
echo $(./WasmEdge/build/tools/wasmedge/wasmedge)
./build.sh ./WasmEdge/build/tools/wasmedge/wasmedge
