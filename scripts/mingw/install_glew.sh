#!/bin/bash

echo "* * * install GLEW for mingw * * *"

MINGW_DIR=build/x86_64-w64-mingw32

GLEW_URL="https://github.com/nigels-com/glew/releases/download/glew-2.1.0/glew-2.1.0-win32.zip"

if [ ! -e ${MINGW_DIR}/glew-2.1.0 ]; then
  if [ ! -e ${MINGW_DIR}/glew-2.1.0-win32.zip ]; then
    echo "Download ${GLEW_URL}"
    curl --progress-bar -S -L -o ${MINGW_DIR}/glew-2.1.0-win32.zip $GLEW_URL
  fi
  unzip ${MINGW_DIR}/glew-2.1.0-win32.zip -d ${MINGW_DIR}
fi

# copy
(cd ${MINGW_DIR}; mkdir -p lib include bin)
cp ${MINGW_DIR}/glew-2.1.0/lib/Release/x64/glew32.lib ${MINGW_DIR}/lib/
cp -R ${MINGW_DIR}/glew-2.1.0/include/* ${MINGW_DIR}/include/
cp ${MINGW_DIR}/glew-2.1.0/bin/Release/x64/*.dll ${MINGW_DIR}/bin/
