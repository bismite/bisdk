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

mkdir build

#
# install libraries
#
if [ $HOST = "macos" ]; then
  ./scripts/macos/install_sdl.rb
  ./scripts/macos/install_sdl_image_and_mixer.rb
  ./scripts/macos/install_glew.sh
fi
if [ $MINGW_AVAILABLE ]; then
  ./scripts/mingw/install_sdl.sh
  ./scripts/mingw/install_glew.sh
fi

#
# download bi-core and bi-ext
#

if [ ! -e $BI_CORE_DIR ]; then
  if [ -z $BI_CORE ]; then
    git clone https://github.com/bismite/bi-core.git $BI_CORE_DIR
  else
    cp -R $BI_CORE build/
    rm -rf $BI_CORE_DIR/build
  fi
fi

if [ ! -e $BI_EXT_DIR ]; then
  if [ -z $BI_EXT ]; then
    git clone https://github.com/bismite/bi-ext.git $BI_EXT_DIR
  else
    cp -R $BI_EXT build/
    rm -rf $BI_EXT_DIR/build
  fi
fi

#
# build bi-core and bi-ext
#
echo "* * * build bi-core and bi-ext * * *"

_copy_headers_ () {
  mkdir -p $1/include
  cp -R $BI_CORE_DIR/include/* $1/include
  cp -R $BI_EXT_DIR/include/* $1/include
}

_copy_lib_ () {
  mkdir -p $2/lib
  cp $BI_CORE_DIR/build/$1/libbi.a $2/lib
  cp $BI_EXT_DIR/build/$1/libbiext.a $2/lib
}

INSTALL_PATH="${BI_BUILDER_ROOT}/build/$HOST"
_copy_headers_ $INSTALL_PATH
INCLUDE_PATHS="-I ${INSTALL_PATH}/include -I ${INSTALL_PATH}/include/SDL2"
(cd $BI_CORE_DIR; make -f Makefile.$HOST.mk "INCLUDE_PATHS=$INCLUDE_PATHS")
(cd $BI_EXT_DIR; make -f Makefile.$HOST.mk "INCLUDE_PATHS=$INCLUDE_PATHS")
_copy_lib_ $HOST $INSTALL_PATH


if [ $MINGW_AVAILABLE ]; then
  INSTALL_PATH="${BI_BUILDER_ROOT}/build/x86_64-w64-mingw32"
  _copy_headers_ $INSTALL_PATH
  INCLUDE_PATHS="-I ${INSTALL_PATH}/include"
  CFLAGS="-std=c11 -O3 -Wall -Werror=implicit-function-declaration `${INSTALL_PATH}/bin/sdl2-config --cflags`"
  (cd $BI_CORE_DIR; make -f Makefile.mingw.mk "INCLUDE_PATHS=$INCLUDE_PATHS" "CFLAGS=$CFLAGS")
  (cd $BI_EXT_DIR; make -f Makefile.mingw.mk "INCLUDE_PATHS=$INCLUDE_PATHS" "CFLAGS=$CFLAGS" )
  _copy_lib_ mingw $INSTALL_PATH
fi

if [ $EMSCRIPTEN_AVAILABLE ]; then
  INSTALL_PATH="${BI_BUILDER_ROOT}/build/emscripten"
  _copy_headers_ $INSTALL_PATH
  INCLUDE_PATHS="-I ${INSTALL_PATH}/include"
  CFLAGS="-std=c11 -Oz -Wall -Werror=implicit-function-declaration -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png]"
  (cd $BI_CORE_DIR; make -f Makefile.emscripten.mk "INCLUDE_PATHS=$INCLUDE_PATHS" "CFLAGS=$CFLAGS")
  (cd $BI_EXT_DIR; make -f Makefile.emscripten.mk "INCLUDE_PATHS=$INCLUDE_PATHS" "CFLAGS=$CFLAGS")
  _copy_lib_ emscripten $INSTALL_PATH
fi
