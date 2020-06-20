require 'rbconfig'
require_relative "common.rb"

FRAMEWORKS_DIR = nil
HOST="linux"

OPTIMIZE = "-O3"
C_STD="-std=gnu11"
CXX_STD="-std=gnu++11"
COMMON_CFLAGS = %W( -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
COMMON_DEFINES = %w(MRB_INT64 MRB_UTF8_STRING)

MRuby::Build.new do |conf|
  toolchain :clang

  conf.enable_bintest = false
  conf.enable_test = false

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include"
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include/SDL2"
  end
  conf.cc.flags = COMMON_CFLAGS + [ OPTIMIZE, C_STD ]
  if HOST == "linux"
    conf.cc.flags << "`sdl2-config --cflags`"
  end

  conf.cxx do |cxx|
    cxx.command = 'clang++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/#{HOST}/include"
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include/SDL2"
  end
  conf.cxx.flags = COMMON_CFLAGS + [ OPTIMIZE, CXX_STD ]
  if HOST == "linux"
    conf.cxx.flags << "`sdl2-config --cflags`"
  end

  conf.linker do |linker|
    linker.command = 'clang'
    linker.library_paths << "#{BUILD_DIR}/#{HOST}/lib"
    # linker.libraries << "stdc++"
    linker.libraries += %W( bi biext GLEW SDL2 SDL2_image SDL2_mixer )
    if HOST == "macos"
      linker.libraries << "mpg123"
      linker.flags << "-framework OpenGL"
    else
      linker.libraries << "GL"
      linker.libraries << "dl"
    end
  end
end
