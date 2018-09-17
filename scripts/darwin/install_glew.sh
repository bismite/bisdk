#!/bin/sh

mkdir -p build/host/lib
mkdir -p build/host/include

if [ ! -e build/host/glew-2.1.0/lib/libGLEW.a ]; then
  if [ ! -e build/host/glew-2.1.0 ]; then
    if [ ! -e build/host/glew-2.1.0.tgz ]; then
      curl -sS -L -o build/host/glew-2.1.0.tgz https://github.com/nigels-com/glew/releases/download/glew-2.1.0/glew-2.1.0.tgz
    fi
    tar zxf build/host/glew-2.1.0.tgz -C build/host/
  fi
  (cd build/host/glew-2.1.0; make glew.lib.static)
fi

# copy glew
cp build/host/glew-2.1.0/lib/* build/host/lib
cp -R build/host/glew-2.1.0/include/* build/host/include
