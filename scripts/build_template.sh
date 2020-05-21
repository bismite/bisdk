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

run () {
  echo $1
  $1
  ret=$?; if [ $ret != 0 ]; then
    echo "failed..."
    exit $ret;
  fi
}

#
# compile mrb
#
export PATH=$PWD/build/${HOST}/bin:$PATH
run "bicompile src/main.rb build/template/main.mrb"

#
# compile template main executable
#
_update_link_ () {
  local FRAMEWORK="$1.framework/Versions/A/$1"
  install_name_tool -change "@rpath/$FRAMEWORK" "@executable_path/../Frameworks/$FRAMEWORK" "$2"
}

_copy_license_files_ () {
  mkdir -p $2
  cp build/licenses/$1/* $2
}

build_macos_template () {
  mkdir -p build/template/
  local DIR="build/template/macos"
  local RES_DIR="$DIR/template.app/Contents/Resources"
  local APP_MAIN_EXE="$RES_DIR/main"
  # copy template
  # rsync -a --delete src/template.app $DIR/
  cp -R src/template.app $DIR/
  # main executable
  ./scripts/build_biexec.rb $HOST src/main.c $APP_MAIN_EXE
  cp build/template/main.mrb $DIR/template.app/Contents/Resources/
  # copy libs
  mkdir -p $RES_DIR
  cp build/macos/lib/libmpg123.0.dylib $RES_DIR
  cp build/macos/lib/libSDL2-2.0.0.dylib $RES_DIR
  cp build/macos/lib/libSDL2_mixer-2.0.0.dylib $RES_DIR
  cp build/macos/lib/libSDL2_image-2.0.0.dylib $RES_DIR
  cp build/macos/lib/libhidapi.dylib $RES_DIR
  # update library search path
  ./scripts/macos/update_install_name.rb "build/template/macos/template.app/Contents/Resources" "main"
  # copy licenses
  _copy_license_files_ macos $DIR/licenses/
}

build_linux_template () {
  mkdir -p build/template/$HOST/
  ./scripts/build_biexec.rb $HOST src/main.c build/template/$HOST/main
  cp build/template/main.mrb build/template/$HOST/main.mrb
  _copy_license_files_ linux build/template/linux/licenses
}

build_mingw_template () {
  ./scripts/build_biexec.rb mingw src/main.c build/template/x86_64-w64-mingw32/main.exe
  cp build/template/main.mrb build/template/x86_64-w64-mingw32/main.mrb
  # copy dlls for template
  cp build/x86_64-w64-mingw32/bin/*.dll build/template/x86_64-w64-mingw32/
  _copy_license_files_ mingw build/template/x86_64-w64-mingw32/licenses
}

build_wasm_template () {
  ./scripts/build_biexec.rb wasm src/main-emscripten.c src/support-emscripten.c build/template/wasm/index.html
  ret=$?; if [ $ret != 0 ]; then exit $ret; fi
  cp build/template/main.mrb build/template/wasm/main.mrb
  _copy_license_files_ emscripten build/template/wasm/licenses
}

build_js_template () {
  ./scripts/build_biexec.rb js src/main-emscripten.c src/support-emscripten.c build/template/js/index.html
  ret=$?; if [ $ret != 0 ]; then exit $ret; fi
  cp build/template/main.mrb build/template/js/main.mrb
  _copy_license_files_ emscripten build/template/js/licenses
}

if [ $HOST = "macos" ]; then
  build_macos_template
else
  build_linux_template
fi
if [ $MINGW_AVAILABLE ]; then
  build_mingw_template
fi
if [ $EMSCRIPTEN_AVAILABLE ]; then
  build_wasm_template
  build_js_template
fi
