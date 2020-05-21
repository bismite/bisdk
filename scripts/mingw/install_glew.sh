#!/bin/bash

echo "* * * install GLEW for mingw * * *"

MINGW_DIR=build/x86_64-w64-mingw32


if [ ! -e ${MINGW_DIR}/glew-2.1.0 ]; then
  unzip build/download/glew-2.1.0-win32.zip -d ${MINGW_DIR}
fi

# copy
(cd ${MINGW_DIR}; mkdir -p lib include bin)
cp ${MINGW_DIR}/glew-2.1.0/lib/Release/x64/glew32.lib ${MINGW_DIR}/lib/
cp -R ${MINGW_DIR}/glew-2.1.0/include/* ${MINGW_DIR}/include/
cp ${MINGW_DIR}/glew-2.1.0/bin/Release/x64/*.dll ${MINGW_DIR}/bin/
