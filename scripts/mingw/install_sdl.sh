#!/bin/sh
SDL2_TGZ="SDL2-devel-2.0.8-mingw.tar.gz"
SDL2_URL="https://www.libsdl.org/release/${SDL2_TGZ}"

SDL2_IMAGE_TGZ="SDL2_image-devel-2.0.3-mingw.tar.gz"
SDL2_IMAGE_URL="https://www.libsdl.org/projects/SDL_image/release/${SDL2_IMAGE_TGZ}"

SDL2_MIXER_TGZ="SDL2_mixer-devel-2.0.2-mingw.tar.gz"
SDL2_MIXER_URL="https://www.libsdl.org/projects/SDL_mixer/release/${SDL2_MIXER_TGZ}"

mkdir -p ${BI_BUILDER_ROOT}/build/mingw
mkdir -p ${BI_BUILDER_ROOT}/build/i686-w64-mingw32
mkdir -p ${BI_BUILDER_ROOT}/build/x86_64-w64-mingw32

if [ ! -e ${BI_BUILDER_ROOT}/build/x86_64-w64-mingw32/lib/libSDL2.a ]; then
  if [ ! -e build/mingw/SDL2-2.0.8 ]; then
    if [ ! -e build/mingw/${SDL2_TGZ} ]; then
      curl -sS -L -o build/mingw/${SDL2_TGZ} ${SDL2_URL}
    fi

    tar -xzf build/mingw/${SDL2_TGZ} -C build/mingw
  fi

  (cd build/mingw/SDL2-2.0.8; make cross CROSS_PATH=${BI_BUILDER_ROOT}/build)
fi

if [ ! -e ${BI_BUILDER_ROOT}/build/x86_64-w64-mingw32/lib/libSDL2_image.a ]; then
  if [ ! -e build/mingw/SDL2_image-2.0.3 ]; then
    if [ ! -e build/mingw/${SDL2_IMAGE_TGZ} ]; then
      curl -sS -L -o build/mingw/${SDL2_IMAGE_TGZ} ${SDL2_IMAGE_URL}
    fi

    tar -xzf build/mingw/${SDL2_IMAGE_TGZ} -C build/mingw
  fi

  (cd build/mingw/SDL2_image-2.0.3; make cross CROSS_PATH=${BI_BUILDER_ROOT}/build)
fi


if [ ! -e ${BI_BUILDER_ROOT}/build/x86_64-w64-mingw32/lib/libSDL2_mixer.a ]; then
  if [ ! -e build/mingw/SDL2_mixer-2.0.2 ]; then
    if [ ! -e build/mingw/${SDL2_MIXER_TGZ} ]; then
      curl -sS -L -o build/mingw/${SDL2_MIXER_TGZ} ${SDL2_MIXER_URL}
    fi

    tar -xzf build/mingw/${SDL2_MIXER_TGZ} -C build/mingw
  fi

  (cd build/mingw/SDL2_mixer-2.0.2; make cross CROSS_PATH=${BI_BUILDER_ROOT}/build)
fi
