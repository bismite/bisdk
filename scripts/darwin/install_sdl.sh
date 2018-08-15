#!/bin/sh

FRAMEWORKS_DIR=$HOME/Library/Frameworks
mkdir -p $FRAMEWORKS_DIR

mkdir -p build/host/

# SDL2
SDL2_FRAMEWORK=SDL2.framework
SDL2_DMG=SDL2-2.0.8.dmg
if [ ! -e $FRAMEWORKS_DIR/$SDL2_FRAMEWORK ]; then
  if [ ! -e build/host/$SDL2_DMG ]; then
    curl -L -o build/host/$SDL2_DMG https://www.libsdl.org/release/$SDL2_DMG
  fi
  hdiutil attach build/host/$SDL2_DMG
  cp -R /Volumes/SDL2/$SDL2_FRAMEWORK $FRAMEWORKS_DIR
  hdiutil detach /Volumes/SDL2
fi

# SDL2_image
SDL2_IMAGE_FRAMEWORK=SDL2_image.framework
SDL2_IMAGE_DMG=SDL2_image-2.0.3.dmg
if [ ! -e $FRAMEWORKS_DIR/$SDL2_IMAGE_FRAMEWORK ]; then
  if [ ! -e build/host/$SDL2_IMAGE_DMG ]; then
    curl -L -o build/host/$SDL2_IMAGE_DMG https://www.libsdl.org/projects/SDL_image/release/$SDL2_IMAGE_DMG
  fi
  hdiutil attach build/host/$SDL2_IMAGE_DMG
  cp -R /Volumes/SDL2_image/$SDL2_IMAGE_FRAMEWORK $FRAMEWORKS_DIR
  hdiutil detach /Volumes/SDL2_image
fi
