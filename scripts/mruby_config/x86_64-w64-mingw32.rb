require 'rbconfig'
require_relative "common.rb"

OPTIMIZE = "-Os"
C_STD="-std=gnu11"
CXX_STD="-std=gnu++11"
COMMON_CFLAGS = %W( -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
COMMON_DEFINES = %w(MRB_INT64 MRB_UTF8_STRING)

MRuby::Build.new do |conf|
  toolchain :clang
end

MRuby::CrossBuild.new('x86_64-w64-mingw32') do |conf|
  toolchain :gcc
  conf.host_target = "x86_64-w64-mingw32"

  conf.enable_bintest = false
  conf.enable_test = false

  include_gems(conf)

  conf.cc do |cc|
    cc.command = 'x86_64-w64-mingw32-gcc'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/#{conf.host_target}/include"
    cc.flags = COMMON_CFLAGS + [OPTIMIZE, C_STD]
    cc.flags << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --cflags`"
  end

  conf.cxx do |cxx|
    cxx.command = 'x86_64-w64-mingw32-g++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/#{conf.host_target}/include"
    cxx.flags = COMMON_CFLAGS + [OPTIMIZE, CXX_STD]
    cxx.flags << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --cflags`"
  end

  conf.linker do |linker|
    linker.command = 'x86_64-w64-mingw32-gcc'
    linker.library_paths << "#{BUILD_DIR}/#{conf.host_target}/lib"
    linker.libraries += %w(bismite-ext bismite-core glew32 opengl32)
    linker.flags_after_libraries << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --libs` -lSDL2_image -lSDL2_mixer -static-libgcc -mconsole"
  end

  conf.exts do |exts|
    exts.executable = '.exe'
  end

  conf.archiver.command = 'x86_64-w64-mingw32-ar'
end

