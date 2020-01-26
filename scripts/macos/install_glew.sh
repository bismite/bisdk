#!/bin/sh

echo "* * * install GLEW for macos * * *"

GLEW_URL="https://github.com/nigels-com/glew/releases/download/glew-2.1.0/glew-2.1.0.tgz"

mkdir -p build/macos/lib
mkdir -p build/macos/include

if [ ! -e build/macos/glew-2.1.0/lib/libGLEW.a ]; then
  if [ ! -e build/macos/glew-2.1.0 ]; then
    if [ ! -e build/macos/glew-2.1.0.tgz ]; then
      echo "Download ${GLEW_URL}"
      curl --progress-bar -S -L -o build/macos/glew-2.1.0.tgz $GLEW_URL
    fi
    tar zxf build/macos/glew-2.1.0.tgz -C build/macos/
  fi
  (cd build/macos/glew-2.1.0; make glew.lib.static)
fi

# copy glew
cp build/macos/glew-2.1.0/lib/* build/macos/lib
cp -R build/macos/glew-2.1.0/include/* build/macos/include
