#!/bin/sh

export BI_BUILDER_ROOT=${PWD}

UNAME="$(uname -s)"
case "$UNAME" in
    Linux*)   HOST=Linux;;
    Darwin*)  HOST=Darwin;;
    *)        HOST="$UNAME"
esac
echo $HOST

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
# download
#

if [ ! -e $BI_CORE_DIR ]; then git clone https://github.com/bismite/bi-core.git $BI_CORE_DIR; fi
if [ ! -e $BI_EXT_DIR ]; then git clone https://github.com/bismite/bi-ext.git $BI_EXT_DIR; fi

#
# host build
#
if [ $HOST = "Darwin" ] || [ $HOST = "Linux" ]; then

  if [ $HOST = "Darwin" ]; then
    ./scripts/darwin/install_sdl.sh
    ./scripts/darwin/install_glew.sh
  fi

  ./scripts/build_bi_core.sh host; ret=$?; if [ $ret != 0 ]; then exit $ret; fi
  ./scripts/build_bi_ext.sh host; ret=$?; if [ $ret != 0 ]; then exit $ret; fi

fi

#
# mingw build
#
if [ $MINGW_AVAILABLE ]; then

  ./scripts/mingw/install_sdl.sh
  ./scripts/mingw/install_glew.sh
  ./scripts/build_bi_core.sh mingw; ret=$?; if [ $ret != 0 ]; then exit $ret; fi
  ./scripts/build_bi_ext.sh mingw; ret=$?; if [ $ret != 0 ]; then exit $ret; fi

fi

#
# emscripten build
#
if [ $EMSCRIPTEN_AVAILABLE ]; then
  ./scripts/build_bi_core.sh emscripten; ret=$?; if [ $ret != 0 ]; then exit $ret; fi
  ./scripts/build_bi_ext.sh emscripten; ret=$?; if [ $ret != 0 ]; then exit $ret; fi
fi

#
# build mruby
#
if [ ! -e build/mruby ]; then git clone -b 1.4.1 https://github.com/mruby/mruby.git build/mruby; fi
( cd build/mruby; rake -v )
ret=$?; if [ $ret != 0 ]; then exit $ret; fi

#
# copy bin, lib, include
#

mkdir -p build/host/bin
cp build/mruby/build/host/bin/* build/host/bin
cp build/mruby/build/host/lib/libmruby.a build/host/lib/
cp -R build/mruby/include/* build/host/include/

if [ $MINGW_AVAILABLE ]; then
  cp build/mruby/build/mingw/bin/* build/x86_64-w64-mingw32/bin
  cp build/mruby/build/mingw/lib/libmruby.a build/x86_64-w64-mingw32/lib/
  cp -R build/mruby/include/* build/x86_64-w64-mingw32/include/
fi

if [ $EMSCRIPTEN_AVAILABLE ]; then
  cp build/mruby/build/emscripten/lib/libmruby.a build/emscripten/lib/
  cp -R build/mruby/include/* build/emscripten/include/
fi

# instal bibuild
(
  cd build/host/bin/;
  ln -sf ../../../scripts/bibuild.rb bibuild;
)
