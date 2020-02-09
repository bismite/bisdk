#!/bin/bash

#
# create release package
#


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
_copy_bin_ () {
  local DIR="build/$1/bisdk/bin"
  rsync -a --delete build/$1/bin/ $DIR/
  rm $DIR/*.txt # license files in mingw
  cp src/bicompile.rb $DIR
  cp src/birun.rb $DIR
  cp src/biexport.rb $DIR
  cp src/bipackager.rb $DIR
}

_copy_bin_ "macos"
_copy_bin_ "linux"
_copy_bin_ "x86_64-w64-mingw32"
