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


if [ $HOST = "macos" ]; then
  (cd build/macos; zip --symlinks -r template-macos.zip template -x "*/\__MACOSX" -x "*/\.*")
else
  (cd build/linux; zip --symlinks -r template-linux.zip template -x "*/\__MACOSX" -x "*/\.*")
fi

if [ $MINGW_AVAILABLE ]; then
  (cd build/x86_64-w64-mingw32; zip --symlinks -r template-x86_64-w64-mingw32.zip template -x "*/\__MACOSX" -x "*/\.*")
fi

if [ $EMSCRIPTEN_AVAILABLE ]; then
  (cd build/emscripten; zip --symlinks -r template-emscripten.zip template -x "*/\__MACOSX" -x "*/\.*")
fi
