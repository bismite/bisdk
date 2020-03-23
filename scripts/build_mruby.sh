#!/bin/bash

export BI_BUILDER_ROOT=${PWD}
echo "$BI_BUILDER_ROOT"

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

export BI_CORE_DIR=build/bi-core
export BI_EXT_DIR=build/bi-ext

export MRUBY_CONFIG="${PWD}/scripts/build_config.rb"
export MRUBY_BUILD_DIR="${PWD}/build/$HOST/mruby"

MRUBY_DIR="mruby-2.1.0"

#
# build mruby
#
if [ ! -e build/download/mruby-2.1.0.tar.gz ]; then
  curl --progress-bar -S -L -o build/download/mruby-2.1.0.tar.gz https://github.com/mruby/mruby/archive/2.1.0.tar.gz
fi
tar zxf build/download/mruby-2.1.0.tar.gz -C build/
(cd build/$MRUBY_DIR ; rake -v)
ret=$?; if [ $ret != 0 ]; then exit $ret; fi

#
# install mruby
#
install_mruby () {
  echo " * install mruby to $2"
  mkdir -p build/$2/bin/ build/$2/include/ build/$2/lib/

  cp -v build/$HOST/mruby/$1/bin/* build/$2/bin/
  rm build/$2/bin/mruby-config
  cp -v build/$HOST/mruby/$1/lib/* build/$2/lib/
  cp -v -R build/$MRUBY_DIR/include build/$2/
}

install_mruby "host" $HOST
if [ $MINGW_AVAILABLE ]; then
  install_mruby "mingw" "x86_64-w64-mingw32";
  # copy dll
  if [ $HOST = "macos" ]; then
    # macports
    cp -v /opt/local/x86_64-w64-mingw32/bin/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
    # homebrew
    cp -v /usr/local/Cellar/mingw-w64/7.0.0_1/toolchain-x86_64/x86_64-w64-mingw32/bin/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
  else
    cp -v /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
  fi
fi
if [ $EMSCRIPTEN_AVAILABLE ]; then
  install_mruby "emscripten" "emscripten"
fi
