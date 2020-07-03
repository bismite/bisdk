[![Build Status](https://travis-ci.org/bismite/bismite-sdk.svg?branch=master)](https://travis-ci.org/bismite/bismite-sdk)

[English](README.md) | [日本語](README.ja.md)

# Bismite SDK

Bismite SDK is a multi-platform development environment for controlling 2D graphics and sound.

It runs on macOS, Linux, Windows, and web browsers.
WebGL and WebAssembly are required to run in a web browser.

Screenshots and Live Demo : https://bismite.github.io/

## Install

For example: Unzip the archive into a `$HOME/.bismite` and set the PATH environment variable to `$HOME/.bismite/bin`.

## Usage

- `birun source.rb` : Run the program.
- `bipackassets path/to/assets path/to/output SECRET` : Archive the assets directory
- `biunpackassets assets.dat SECRET` : Expand the archived assets.
- `biexport <target> source.rb assets.dat path/to/output` : Export to the target platform.
  - Select the target platform from `macos`, `linux`, `windows`, `wasm`, `wasm-dl` and `js` You can.


## Development

It can be built on Linux or macOS.
Building for the browser requires [emscripten](https://emscripten.org/).
Building for Windows requires [mingw-w64](http://mingw-w64.org/doku.php).

`. /scripts/setup.sh` command to start the build.
You can select `macos`, `linux`, `mingw` and `emscripten` as build targets.
These targets can be specified one or more, and unavailable targets are simply ignored.
If `all` is specified, starts to build all available targets.
With no arguments, only the host system is targeted.

### Development on Linux

`setup.sh` requires ruby, SDL2, GLEW, bison etc.
These packages can be installed with the following command (On Ubuntu 20.04)

```
sudo apt-get install clang libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libglew-dev ruby bison git curl
```

# License

Copyright 2018-2020 kbys <work4kbys@gmail.com>

Apache License Version 2.0
