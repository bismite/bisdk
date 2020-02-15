#!/bin/bash

UNAME="$(uname -s)"
case "$UNAME" in
    Darwin*)  HOST=macos;;
    *)        HOST=linux;;
esac
echo "Host is $HOST"

if type x86_64-w64-mingw32-gcc > /dev/null 2>&1; then
  export MINGW_AVAILABLE=1;
  echo MINGW_AVAILABLE
fi
if type emcc > /dev/null 2>&1; then
  export EMSCRIPTEN_AVAILABLE=1;
  echo EMSCRIPTEN_AVAILABLE
fi

mkdir -p build/licenses

#
# copy license files
#

copy_linux_licenses () {
  local LICENSE_DIR=build/licenses/$HOST
  mkdir -p $LICENSE_DIR
  cp build/$HOST/mruby/host/LEGAL $LICENSE_DIR/LEGAL.mruby.txt
  cp build/bi-core/LICENSE $LICENSE_DIR/LICENSE.bi-core.txt
  cp build/bi-ext/LICENSE $LICENSE_DIR/LICENSE.bi-ext.txt
}

copy_macos_licenses () {
  local LICENSE_DIR=build/licenses/$HOST
  mkdir -p $LICENSE_DIR
  cp build/$HOST/mruby/host/LEGAL $LICENSE_DIR/LEGAL.mruby.txt
  cp build/macos/glew-2.1.0/LICENSE.txt $LICENSE_DIR/LICENSE.glew.txt
  cp build/bi-core/LICENSE $LICENSE_DIR/LICENSE.bi-core.txt
  cp build/bi-ext/LICENSE $LICENSE_DIR/LICENSE.bi-ext.txt
  cp build/macos/mpg123-1.25.13/COPYING $LICENSE_DIR/COPYING.mpg123.txt
}

copy_mingw_licenses () {
  # copy license files
  LICENSE_DIR=build/licenses/mingw
  mkdir -p $LICENSE_DIR
  cp build/x86_64-w64-mingw32/bin/*.txt $LICENSE_DIR/
  cp build/$HOST/mruby/mingw/LEGAL $LICENSE_DIR/LEGAL.mruby.txt

  cp src/licenses/mingw/* $LICENSE_DIR/

  MINGW_LICENSE_FROM="https://raw.githubusercontent.com/mirror/mingw-w64/v7.0.0"
  echo "Download mingw-w64 license files from $MINGW_LICENSE_FROM"
  (cd $LICENSE_DIR; curl -OJL "${MINGW_LICENSE_FROM}/COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt")
  (cd $LICENSE_DIR; curl -OJL "${MINGW_LICENSE_FROM}/COPYING.MinGW-w64/COPYING.MinGW-w64.txt")
  (cd $LICENSE_DIR; curl -L -o "COPYING.winpthreads.txt" "${MINGW_LICENSE_FROM}/mingw-w64-libraries/winpthreads/COPYING")

  cp build/bi-core/LICENSE $LICENSE_DIR/LICENSE.bi-core.txt
  cp build/bi-ext/LICENSE $LICENSE_DIR/LICENSE.bi-ext.txt
}

copy_emscripten_licenses () {
  # copy license files
  LICENSE_DIR=build/licenses/emscripten
  mkdir -p $LICENSE_DIR

  cp build/$HOST/mruby/emscripten/LEGAL $LICENSE_DIR/LEGAL.mruby.txt
  EMDIR=`which emcc`
  EMDIR=`dirname $EMDIR`
  # emscripten itself
  cp $EMDIR/LICENSE $LICENSE_DIR/LICENSE.emscripten.txt
  cp $EMDIR/AUTHORS $LICENSE_DIR/AUTHORS.emscripten.txt
  # LLVM
  cp $EMDIR/system/lib/libcxx/LICENSE.TXT $LICENSE_DIR/LICENSE.libcxx.txt
  cp $EMDIR/system/lib/libcxx/CREDITS.TXT $LICENSE_DIR/CREDITS.libcxx.txt
  cp $EMDIR/system/lib/libcxxabi/LICENSE.TXT $LICENSE_DIR/LICENSE.libcxxabi.txt
  cp $EMDIR/system/lib/libcxxabi/CREDITS.TXT $LICENSE_DIR/CREDITS.libcxxabi.txt
  cp $EMDIR/system/lib/libunwind/LICENSE.TXT $LICENSE_DIR/LICENSE.libunwind.txt
  cp $EMDIR/system/lib/compiler-rt/LICENSE.TXT $LICENSE_DIR/LICENSE.compiler-rt.txt
  cp $EMDIR/system/lib/compiler-rt/CREDITS.TXT $LICENSE_DIR/CREDITS.compiler-rt.txt
  # musl
  cp $EMDIR/system/lib/libc/musl/COPYRIGHT $LICENSE_DIR/COPYRIGHT.musl.txt
  # bi
  cp build/bi-core/LICENSE $LICENSE_DIR/LICENSE.bi-core.txt
  cp build/bi-ext/LICENSE $LICENSE_DIR/LICENSE.bi-ext.txt
}

if [ $HOST = "macos" ]; then
  copy_macos_licenses
else
  copy_linux_licenses
fi

if [ $MINGW_AVAILABLE ]; then
  copy_mingw_licenses
fi

if [ $EMSCRIPTEN_AVAILABLE ]; then
  copy_emscripten_licenses
fi
