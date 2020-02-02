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
# compile template main executable
#
_update_link_ () {
  local FRAMEWORK="$1.framework/Versions/A/$1"
  install_name_tool -change "@rpath/$FRAMEWORK" "@executable_path/../Frameworks/$FRAMEWORK" "$2"
}

if [ $HOST = "macos" ]; then
  APP_MAIN_EXE="build/macos/template/template.app/Contents/Resources/main"
  # copy template
  rsync -a --delete src/template.app build/macos/template/
  ./scripts/build_biexec.rb $HOST src/main.c $APP_MAIN_EXE
  # copy frameworks
  mkdir -p build/macos/template/template.app/Contents/Frameworks
  rsync -a --delete $HOME/Library/Frameworks/SDL2* "build/macos/template/template.app/Contents/Frameworks/."
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
fi
if [ $EMSCRIPTEN_AVAILABLE ]; then
  ./scripts/build_biexec.rb emscripten src/main-emscripten.c src/support-emscripten.c build/emscripten/template/main.html
fi
