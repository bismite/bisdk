
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
  mkdir -p build/bisdk/macos/bisdk
else
  mkdir -p build/bisdk/linux/bisdk
fi
if [ $MINGW_AVAILABLE ]; then
  mkdir -p build/bisdk/mingw/bisdk
fi

#
# unzip templates
#
unzip_templates () {
  local DIR=$1/share/bisdk/template
  mkdir -p $DIR
  unzip -qo build/bisdk/template-macos.zip -d $DIR/
  unzip -qo build/bisdk/template-x86_64-w64-mingw32.zip -d $DIR/
  unzip -qo build/bisdk/template-linux.zip -d $DIR/
  unzip -qo build/bisdk/template-emscripten.zip -d $DIR/
}
if [ $HOST = "macos" ]; then
  unzip_templates "build/bisdk/macos/bisdk"
else
  unzip_templates "build/bisdk/linux/bisdk"
fi
if [ $MINGW_AVAILABLE ]; then
  unzip_templates "build/bisdk/windows/bisdk"
fi

#
# copy license files
#
_copy_license_files_ () {
  mkdir -p $2
  cp build/licenses/$1/* $2
}
if [ $HOST = "macos" ]; then
  _copy_license_files_ "macos" "build/bisdk/macos/bisdk/licenses"
else
  _copy_license_files_ "linux" "build/bisdk/linux/bisdk/licenses"
fi
if [ $MINGW_AVAILABLE ]; then
  _copy_license_files_ "mingw" "build/bisdk/windows/bisdk/licenses"
fi

#
# copy bisdk/bin
#

echo " * * * bisdk/$HOST"
BISDK_DIR="build/bisdk/$HOST/bisdk"
mkdir -p $BISDK_DIR/bin/
rsync -a --delete build/$HOST/bin/ $BISDK_DIR/bin/
cp src/bicompile.rb $BISDK_DIR/bin/
cp src/birun.rb $BISDK_DIR/bin/
cp src/biexport.rb $BISDK_DIR/bin/
cp src/bipackager.rb $BISDK_DIR/bin/

if [ $MINGW_AVAILABLE ]; then
  echo " * * * bisdk/windows"
  BISDK_DIR="build/bisdk/windows/bisdk"
  mkdir -p $BISDK_DIR/bin
  cp build/x86_64-w64-mingw32/bin/*.exe $BISDK_DIR/bin
  cp build/x86_64-w64-mingw32/bin/*.dll $BISDK_DIR/bin
  cp src/bicompile.rb $BISDK_DIR/bin
  cp src/birun.rb $BISDK_DIR/bin
  cp src/biexport.rb $BISDK_DIR/bin
  cp src/bipackager.rb $BISDK_DIR/bin
fi
