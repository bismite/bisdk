[![Build Status](https://travis-ci.org/bismite/bismite-sdk.svg?branch=master)](https://travis-ci.org/bismite/bismite-sdk)

# bismite-sdk

bismite SDK is a multi-platform development environment for controlling 2D graphics and sound.

It runs on macOS, Linux, Windows, and web browsers.
WebGL and WebAssembly are required to run in a web browser.

Screenshots and Live Demo : https://bismite.github.io/

## compile

`./scripts/setup.sh`

## build in linux

setup.sh requires ruby, SDL2, GLEW, bison etc.
These packages can be installed with the following command (On Ubuntu 20.04)

```
sudo apt-get install clang libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libglew-dev ruby bison git curl
```

# License

Copyright 2018-2020 kbys <work4kbys@gmail.com>

Apache License Version 2.0
