#!/bin/bash

echo "* * * install dlfcn for mingw * * *"

MINGW_DIR=build/x86_64-w64-mingw32

mkdir -p ${MINGW_DIR}/dlfcn

tar xf build/download/mingw-w64-x86_64-dlfcn-1.2.0-1-any.pkg.tar.xz -C ${MINGW_DIR}/dlfcn

# copy
(cd ${MINGW_DIR}; mkdir -p lib include bin)
cp ${MINGW_DIR}/dlfcn/mingw64/include/* ${MINGW_DIR}/include/
cp ${MINGW_DIR}/dlfcn/mingw64/bin/libdl.dll ${MINGW_DIR}/bin/
cp ${MINGW_DIR}/dlfcn/mingw64/bin/libdl.dll ${MINGW_DIR}/lib/
