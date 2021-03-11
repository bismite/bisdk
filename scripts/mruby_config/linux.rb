require 'rbconfig'
require_relative "common.rb"

FRAMEWORKS_DIR = nil
HOST="linux"

OPTIMIZE = "-Os"
C_STD="-std=gnu11"
CXX_STD="-std=gnu++11"
COMMON_CFLAGS = %W( -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
COMMON_DEFINES = %w(MRB_INT64 MRB_UTF8_STRING)

MRuby::Build.new do |conf|
  toolchain :clang

  #conf.enable_bintest = false
  #conf.enable_test = false

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include"
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include/SDL2"
    cc.flags = COMMON_CFLAGS + [ OPTIMIZE, C_STD ]
    cc.flags << "`sdl2-config --cflags`"
    cc.flags << "-fPIC"
  end

  conf.cxx do |cxx|
    cxx.command = 'clang++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/#{HOST}/include"
    cxx.include_paths << "#{BUILD_DIR}/#{HOST}/include/SDL2"
    cxx.flags = COMMON_CFLAGS + [ OPTIMIZE, CXX_STD ]
    cxx.flags << "`sdl2-config --cflags`"
  end

  conf.linker do |linker|
    linker.command = 'clang'
    linker.library_paths << "#{BUILD_DIR}/#{HOST}/lib"
    linker.libraries += %W( bismite-core bismite-ext GLEW SDL2 SDL2_image SDL2_mixer )
    linker.libraries << "GL"
  end
end
