#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]

exit if /emscripten/ === TARGET

MRBC="./build/#{TARGET}/mruby/host/bin/mrbc"

DIR = "build/#{TARGET}/tools"
FileUtils.mkdir_p DIR
%w( bicompile.c birun.c bitool.h bitool.rb ).each{|f| FileUtils.copy "src/bitool/#{f}", DIR }

run "#{MRBC} -B bitool_rb -o #{DIR}/bitool_rb.h #{DIR}/bitool.rb"

case TARGET
when /macos/
  %w(bicompile birun).each{|name|
    outfile = "build/macos/bin/#{name}"
    cmd = "clang -Os -std=c11 -Wall #{DIR}/#{name}.c -o #{outfile}"
    cmd << " -I build/macos/include -I build/macos/include/SDL2"
    cmd << " -L build/macos/lib -lmruby -lbi -lbiext -lSDL2 -lSDL2_mixer -lSDL2_image"
    cmd << " -lGLEW -framework OpenGL"
    run cmd
  }

when /linux/
  %w(bicompile birun).each{|name|
    outfile = "build/linux/bin/#{name}"
    cmd = "clang -Os -std=c11 -Wall #{DIR}/#{name}.c -o #{outfile}"
    cmd << " -I build/linux/include `sdl2-config --cflags`"
    cmd << " -L build/linux/lib -lmruby -lbi -lbiext `sdl2-config --libs` -lSDL2_mixer -lSDL2_image"
    cmd << " -lGLEW -lm -lGL -ldl"
    run cmd
  }

when /mingw/
  SDL2_CONFIG = "build/x86_64-w64-mingw32/bin/sdl2-config"
  MRB_FLAGS = "-DMRB_INT64 -DMRB_UTF8_STRING"
  LIBS="-lmruby -lbiext -lbi -lglew32 -lopengl32 -llibdl -lws2_32"
  %w(birun bicompile).each{|name|
    outfile = "build/x86_64-w64-mingw32/bin/#{name}.exe"
    cmd = "x86_64-w64-mingw32-gcc -o #{outfile} #{DIR}/#{name}.c"
    cmd << " -Os -Wall -DNDEBUG -std=c11 "
    cmd << " `#{SDL2_CONFIG} --cflags`"
    cmd << " #{MRB_FLAGS}"
    cmd << " -I build/x86_64-w64-mingw32/include"
    cmd << " -L build/x86_64-w64-mingw32/lib"
    cmd << " #{LIBS}"
    cmd << " `#{SDL2_CONFIG} --libs` -lSDL2_mixer -lSDL2_image -mconsole"
    run cmd
  }
end
