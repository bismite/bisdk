require 'rbconfig'
require_relative "common.rb"

OPTIMIZE = "-O3"
C_STD="-std=gnu11"
CXX_STD="-std=gnu++11"
COMMON_CFLAGS = %W( -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
COMMON_DEFINES = %w(MRB_INT64 MRB_UTF8_STRING)


MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('emscripten') do |conf|
  toolchain :clang

  conf.enable_bintest = false
  conf.enable_test = false

  include_gems(conf)

  emscripten_flags = %W(-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' -s DISABLE_EXCEPTION_CATCHING=0 -s MAIN_MODULE=1 -fPIC -s WASM=1)
  emscripten_optimize_level = "-Oz"

  conf.cc do |cc|
    cc.command = 'emcc'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/emscripten/include"
    cc.flags = COMMON_CFLAGS + [ emscripten_optimize_level, C_STD ]
    cc.flags += emscripten_flags
  end

  conf.cxx do |cxx|
    cxx.command = 'em++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/emscripten/include"
    cxx.flags = COMMON_CFLAGS + [emscripten_optimize_level, CXX_STD]
    cxx.flags += emscripten_flags
  end

  conf.linker do |linker|
    linker.command = 'emcc'
    linker.library_paths << "#{BUILD_DIR}/emscripten/lib"
    linker.libraries += %w(biext bi)
    linker.flags += emscripten_flags
  end

  conf.archiver.command = 'emar'
end
