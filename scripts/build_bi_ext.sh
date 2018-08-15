#!/bin/sh

if [ $1 = "host" ]; then
  INSTALL_PATH="${BI_BUILDER_ROOT}/build/host"
elif [ $1 = "mingw" ]; then
  INSTALL_PATH="${BI_BUILDER_ROOT}/build/x86_64-w64-mingw32"
elif [ $1 = "emscripten" ]; then
  INSTALL_PATH="${BI_BUILDER_ROOT}/build/emscripten"
fi

if [ -e ${INSTALL_PATH}/lib/libbiext.a ]; then
  exit
fi

echo "build bi-core $1"

if [ $1 = "host" ]; then

  UNAME="$(uname -s)"
  case "$UNAME" in
      Linux*)   HOST=Linux;;
      Darwin*)  HOST=Darwin;;
      *)        HOST="$UNAME"
  esac
  if [ $HOST = "Darwin" ]; then
    export HOST_ADDITIONAL_CFLAGS="-F $HOME/Library/Frameworks"
  elif  [ $HOST = "Linux" ]; then
    export HOST_ADDITIONAL_CFLAGS="`sdl2-config --cflags`"
  fi

  CC=/usr/bin/gcc
  AR=/usr/bin/ar
  INCLUDE_PATHS="-I $BI_CORE_DIR/include -I $BI_EXT_DIR/include -I ${INSTALL_PATH}/include"
  CFLAGS="-std=c11 -O3 -Wall $INCLUDE_PATHS $HOST_ADDITIONAL_CFLAGS"

elif [ $1 = "mingw" ]; then

  CC=x86_64-w64-mingw32-gcc
  AR=x86_64-w64-mingw32-ar
  INCLUDE_PATHS="-I $BI_CORE_DIR/include -I $BI_EXT_DIR/include -I ${INSTALL_PATH}/include"
  CFLAGS="-std=c11 -O3 -Wall $INCLUDE_PATHS `${INSTALL_PATH}/bin/sdl2-config --cflags`"

elif [ $1 = "emscripten" ]; then

  CC=emcc
  AR=emar
  INCLUDE_PATHS="-I $BI_CORE_DIR/include -I $BI_EXT_DIR/include"
  CFLAGS="-std=c11 -Oz -Wall -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png] $INCLUDE_PATHS"

fi

# compile
BUILD_DIR=build/$1/bi-ext
mkdir -p $BUILD_DIR

for FILE in `find $BI_EXT_DIR/src/* -type f`
do
  NAME=`basename $FILE`
  $CC -c $FILE -o $BUILD_DIR/$NAME.o $CFLAGS
  if [ $? != 0 ]; then exit; fi
done
$AR -r $BUILD_DIR/libbiext.a $BUILD_DIR/*.o

# copy
mkdir -p ${INSTALL_PATH}/lib
mkdir -p ${INSTALL_PATH}/include
cp $BUILD_DIR/libbiext.a ${INSTALL_PATH}/lib
cp -R $BI_EXT_DIR/include/* ${INSTALL_PATH}/include
