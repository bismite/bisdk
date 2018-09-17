
if [ ! -e build/mingw/glew-2.1.0 ]; then
  if [ ! -e build/mingw/glew-2.1.0-win32.zip ]; then
    curl -sS -L -o build/mingw/glew-2.1.0-win32.zip https://github.com/nigels-com/glew/releases/download/glew-2.1.0/glew-2.1.0-win32.zip
  fi
  unzip build/mingw/glew-2.1.0-win32.zip -d build/mingw
fi

# copy
cp build/mingw/glew-2.1.0/lib/Release/x64/glew32.lib build/x86_64-w64-mingw32/lib
cp -R build/mingw/glew-2.1.0/include/* build/x86_64-w64-mingw32/include
