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


#
# build mruby
#
ln -s $HOST build/host
if [ ! -e build/mruby ]; then git clone -b 2.1.0 https://github.com/mruby/mruby.git build/mruby; fi
(cd build/mruby; rake -v)
ret=$?; if [ $ret != 0 ]; then exit $ret; fi


#
# install mruby
#
install_mruby () {
  mkdir -p build/$2/bin/ build/$2/include/ build/$2/lib/
  cp build/mruby/build/$1/bin/* build/$2/bin/
  rm build/$2/bin/mruby-config
  cp build/mruby/build/$1/lib/* build/$2/lib/
  cp -R build/mruby/include build/$2/
}
install_mruby "host" "host"
if [ $MINGW_AVAILABLE ]; then
  install_mruby "mingw" "x86_64-w64-mingw32";
  # copy dll
  if [ $HOST = "macos" ]; then
    # macports
    cp /opt/local/x86_64-w64-mingw32/bin/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
    # homebrew
    cp /usr/local/Cellar/mingw-w64/7.0.0_1/toolchain-x86_64/x86_64-w64-mingw32/bin/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
  else
    cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
  fi
fi
if [ $EMSCRIPTEN_AVAILABLE ]; then
  install_mruby "emscripten" "emscripten"
fi
