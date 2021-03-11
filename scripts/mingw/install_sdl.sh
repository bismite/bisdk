#!/bin/bash

echo "* * * install SDL2 for mingw * * *"

BI_BUILDER_ROOT=${PWD}

MINGW_DIR=build/x86_64-w64-mingw32

SDL2_VER=2.0.14
SDL2_IMAGE_VER=2.0.5
SDL2_MIXER_VER=2.0.4

SDL2_TGZ="SDL2-devel-${SDL2_VER}-mingw.tar.gz"
SDL2_IMAGE_TGZ="SDL2_image-devel-${SDL2_IMAGE_VER}-mingw.tar.gz"
SDL2_MIXER_TGZ="SDL2_mixer-devel-${SDL2_MIXER_VER}-mingw.tar.gz"

SDL2_DIR="${MINGW_DIR}/SDL2-${SDL2_VER}"
SDL2_IMAGE_DIR="${MINGW_DIR}/SDL2_image-${SDL2_IMAGE_VER}"
SDL2_MIXER_DIR="${MINGW_DIR}/SDL2_mixer-${SDL2_MIXER_VER}"

mkdir -p ${BI_BUILDER_ROOT}/${MINGW_DIR}

_dl_and_make_ () {
  tar -xzf build/download/x86_64-w64-mingw32/$2 -C ${MINGW_DIR}
  (cd $1; make cross CROSS_PATH=${BI_BUILDER_ROOT}/build ARCHITECTURES=x86_64-w64-mingw32)
}

_dl_and_make_ $SDL2_DIR $SDL2_TGZ
_dl_and_make_ $SDL2_IMAGE_DIR $SDL2_IMAGE_TGZ
_dl_and_make_ $SDL2_MIXER_DIR $SDL2_MIXER_TGZ
