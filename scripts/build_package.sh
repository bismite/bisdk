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
# install mruby
#
install_mruby () {
  mkdir -p build/$2/bin/ build/$2/include/ build/$2/lib/
  cp build/mruby/build/$1/bin/* build/$2/bin
  cp build/mruby/build/$1/lib/* build/$2/lib/
  cp -r build/mruby/include build/$2/
}
install_mruby "host" "host"
if [ $MINGW_AVAILABLE ]; then
  install_mruby "mingw" "x86_64-w64-mingw32";
  # copy dll
  if [ $HOST = "macos" ]; then
    cp /opt/local/x86_64-w64-mingw32/bin/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
  else
    cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll build/x86_64-w64-mingw32/bin/
  fi
fi
if [ $EMSCRIPTEN_AVAILABLE ]; then
  install_mruby "emscripten" "emscripten"
fi

#
# compile template main executable
#
_update_link_ () {
  local FRAMEWORK="$1.framework/Versions/A/$1"
  install_name_tool -change "@rpath/$FRAMEWORK" "@executable_path/../Frameworks/$FRAMEWORK" "$2"
}

if [ $HOST = "macos" ]; then
  APP_MAIN_EXE="build/macos/template/template.app/Contents/Resources/main"
  # copy template
  cp -R src/template.app build/macos/template
  ./scripts/build_biexec.rb $HOST src/main.c $APP_MAIN_EXE
  # copy frameworks
  rm -rf "build/macos/template/template.app/Contents/Frameworks"
  mkdir -p "build/macos/template/template.app/Contents/Frameworks"
  cp -R $HOME/Library/Frameworks/SDL2* "build/macos/template/template.app/Contents/Frameworks/."
  ls "build/macos/template/template.app/Contents/Frameworks/"
  # update library search path
  _update_link_ "SDL2" $APP_MAIN_EXE
  _update_link_ "SDL2_image" $APP_MAIN_EXE
  _update_link_ "SDL2_mixer" $APP_MAIN_EXE
  otool -L $APP_MAIN_EXE
else
  ./scripts/build_biexec.rb $HOST src/main.c build/host/template/main
fi
if [ $MINGW_AVAILABLE ]; then
  ./scripts/build_biexec.rb mingw src/main.c build/x86_64-w64-mingw32/template/main.exe
  # copy dlls for template
  cp build/x86_64-w64-mingw32/bin/*.dll build/x86_64-w64-mingw32/template/
  cp /opt/local/x86_64-w64-mingw32/bin/libwinpthread-1.dll build/x86_64-w64-mingw32/template/
fi
if [ $EMSCRIPTEN_AVAILABLE ]; then
  ./scripts/build_biexec.rb emscripten src/main-emscripten.c src/support-emscripten.c build/emscripten/template/main.html
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
    cp -R build/macos/template/ $DIR/share/bisdk/template/macos
  else
    cp -R build/linux/template/ $DIR/share/bisdk/template/linux
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
# copy bisdk/bin
#

echo " * * * bisdk/$HOST"
BISDK_DIR="build/bisdk/$HOST"
mkdir -p $BISDK_DIR/bin/
cp build/host/bin/* $BISDK_DIR/bin/
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
