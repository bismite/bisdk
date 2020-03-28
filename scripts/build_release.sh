#!/bin/bash

mkdir -p build/macos/bisdk
mkdir -p build/linux/bisdk
mkdir -p build/x86_64-w64-mingw32/bisdk

#
# copy templates
#
copy_templates () {
  local DIR=build/$1/bisdk/share/bisdk/template
  mkdir -p $DIR
  rsync -a --delete build/template/macos -d $DIR/
  rsync -a --delete build/template/linux -d $DIR/
  rsync -a --delete build/template/x86_64-w64-mingw32 -d $DIR/
  rsync -a --delete build/template/emscripten -d $DIR/
}

copy_templates "macos"
copy_templates "linux"
copy_templates "x86_64-w64-mingw32"

#
# copy license files
#
_copy_license_files_ () {
  local DIR="build/$2/bisdk/licenses"
  mkdir -p $DIR
  cp build/licenses/$1/* $DIR
}
_copy_license_files_ "macos" "macos"
_copy_license_files_ "linux" "linux"
_copy_license_files_ "mingw" "x86_64-w64-mingw32"

#
# copy bisdk/bin
#
copy_scripts () {
  cp src/biexport.rb $1/biexport
  cp src/bipackassets.rb $1/bipackassets
  cp src/biunpackassets.rb $1/biunpackassets
}
copy_exec () {
  local DIR="build/$1/bisdk/bin"
  mkdir -p $DIR
  cp build/$1/bin/mruby $DIR/
  cp build/$1/bin/mirb $DIR/
  cp build/$1/bin/mrbc $DIR/
  cp build/$1/bin/mruby-strip $DIR/
  cp build/$1/bin/bicompile $DIR/
  cp build/$1/bin/birun $DIR/
  copy_scripts $DIR
}
copy_lib_macos () {
  local src="build/template/macos/template.app/Contents/Resources"
  local DIR="build/macos/bisdk/bin"
  mkdir -p $DIR
  cp $src/libmpg123.0.dylib $DIR/
  cp $src/libSDL2-2.0.0.dylib $DIR/
  cp $src/libSDL2_image-2.0.0.dylib $DIR/
  cp $src/libSDL2_mixer-2.0.0.dylib $DIR/
  cp $src/libhidapi.dylib $DIR/
  # install name
  ./scripts/macos/update_install_name.rb "$DIR" mruby mirb mrbc mruby-strip
}
copy_exec_mingw () {
  local DIR="build/$1/bisdk/bin"
  mkdir -p $DIR
  cp build/$1/bin/mruby.exe $DIR/
  cp build/$1/bin/mirb.exe $DIR/
  cp build/$1/bin/mrbc.exe $DIR/
  cp build/$1/bin/mruby-strip.exe $DIR/
  cp build/$1/bin/bicompile.exe $DIR/
  cp build/$1/bin/birun.exe $DIR/
  cp build/$1/bin/*.dll $DIR/
  # scripts and batch file
  copy_scripts $DIR
  cp src/mingw/*.bat $DIR
}
copy_exec "macos"
copy_lib_macos
copy_exec "linux"
copy_exec_mingw "x86_64-w64-mingw32"

#
# zip
#
zip_release () {
  rm build/$2
  (cd build/$1/; zip --quiet --symlinks -r ../$2 bisdk -x '*/\__MACOSX' -x '*/\.*')
}
zip_release "macos" "bisdk-macos.zip"
zip_release "linux" "bisdk-linux.zip"
zip_release "x86_64-w64-mingw32" "bisdk-windows.zip"
