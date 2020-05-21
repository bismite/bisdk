#!/bin/bash

echo "* * * install GLEW for macos * * *"

mkdir -p build/macos/lib
mkdir -p build/macos/include

if [ ! -e build/macos/glew-2.1.0/lib/libGLEW.a ]; then
  if [ ! -e build/macos/glew-2.1.0 ]; then
    tar zxf build/download/glew-2.1.0.tgz -C build/macos/
  fi
  (cd build/macos/glew-2.1.0; make glew.lib.static)
fi

# copy glew
cp build/macos/glew-2.1.0/lib/* build/macos/lib
cp -R build/macos/glew-2.1.0/include/* build/macos/include
