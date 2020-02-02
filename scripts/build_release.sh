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

#
# create release package
#

mkdir -p build/bisdk
if [ $HOST = "macos" ]; then
  mkdir -p build/bisdk/macos
else
  mkdir -p build/bisdk/linux
fi
if [ $MINGW_AVAILABLE ]; then
  mkdir -p build/bisdk/mingw
fi

#
# copy template
#
copy_template () {
  local DIR=$1
  mkdir -p $DIR/share/bisdk/template
  if [ $HOST = "macos" ]; then
    rsync -a --delete build/macos/template/ $DIR/share/bisdk/template/macos/
  fi
  if [ $MINGW_AVAILABLE ]; then
    cp -R build/x86_64-w64-mingw32/template/ $DIR/share/bisdk/template/x86_64-w64-mingw32
  fi
  if [ $EMSCRIPTEN_AVAILABLE ]; then
    cp -R build/emscripten/template/ $DIR/share/bisdk/template/emscripten
  fi
}
if [ $HOST = "macos" ]; then
  copy_template "build/bisdk/macos"
else
  copy_template "build/bisdk/linux"
fi
if [ $MINGW_AVAILABLE ]; then
  copy_template "build/bisdk/mingw"
fi

#
# license files
#
_copy_license_files_ () {
  mkdir -p $2
  cp build/licenses/$1/* $2
}
if [ $HOST = "macos" ]; then
  _copy_license_files_ "macos" "build/bisdk/macos/licenses"
else
  _copy_license_files_ "linux" "build/bisdk/linux/licenses"
fi
if [ $MINGW_AVAILABLE ]; then
  _copy_license_files_ "mingw" "build/bisdk/mingw/licenses"
fi

#
# copy bisdk/bin
#

echo " * * * bisdk/$HOST"
BISDK_DIR="build/bisdk/$HOST"
mkdir -p $BISDK_DIR/bin/
rsync -a --delete build/host/bin/ $BISDK_DIR/bin/
cp src/bicompile.rb $BISDK_DIR/bin/
cp src/birun.rb $BISDK_DIR/bin/
cp src/biexport.rb $BISDK_DIR/bin/
cp src/bipackager.rb $BISDK_DIR/bin/

if [ $MINGW_AVAILABLE ]; then
  echo " * * * bisdk/mingw"
  BISDK_DIR="build/bisdk/mingw"
  mkdir -p $BISDK_DIR/bin
  cp build/x86_64-w64-mingw32/bin/*.exe $BISDK_DIR/bin
  cp build/x86_64-w64-mingw32/bin/*.dll $BISDK_DIR/bin
  cp src/bicompile.rb $BISDK_DIR/bin
  cp src/birun.rb $BISDK_DIR/bin
  cp src/biexport.rb $BISDK_DIR/bin
  cp src/bipackager.rb $BISDK_DIR/bin
fi
