#!/usr/bin/env ruby
require "fileutils"

BISDK_DIR=File.absolute_path(File.join(File.dirname(__FILE__),".."))

class Compiler
  MRB_FLAGS="-DMRB_INT64 -DMRB_UTF8_STRING"
end

class MacOS < Compiler
  HOST = "macos"
  CC = "clang"
  INCLUDE_PATHS = "-I #{BISDK_DIR}/build/#{HOST}/include -I #{BISDK_DIR}/build/#{HOST}/include/SDL2"
  LIB_PATHS="-L #{BISDK_DIR}/build/#{HOST}/lib"

  LIBS="-lSDL2 -lSDL2_image -lSDL2_mixer -lmpg123 -lmruby -lbiext -lbi -lGLEW -lstdc++"
  FRAMEWORKS="-framework OpenGL"
  CFLAGS="-std=gnu11 -O3 -Wall -DNDEBUG"
  LDFLAGS="#{FRAMEWORKS}"

  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -o #{outfile} #{sources.join(" ")} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS}"
    puts cmd
    system cmd
  end
end

class Linux < Compiler
  HOST =  "linux"
  CC = "clang"
  INCLUDE_PATHS = "-I #{BISDK_DIR}/build/#{HOST}/include"
  LIB_PATHS="-L #{BISDK_DIR}/build/#{HOST}/lib"
  LIBS="-lmruby -lbiext -lbi -lGLEW -lm -lGL"
  CFLAGS="-std=c11 -O3 -Wall -DNDEBUG `sdl2-config --cflags`"
  LDFLAGS="`sdl2-config --libs` -lSDL2_image -lSDL2_mixer"

  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -o #{outfile} #{sources.join(" ")} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS}"
    puts cmd
    system cmd
  end
end

class Mingw < Compiler
  CC="x86_64-w64-mingw32-g++"

  SDL2_CONFIG="#{BISDK_DIR}/build/x86_64-w64-mingw32/bin/sdl2-config"
  INCLUDE_PATHS="-I #{BISDK_DIR}/build/x86_64-w64-mingw32/include"
  LIB_PATHS="-L #{BISDK_DIR}/build/x86_64-w64-mingw32/lib"

  LIBS="-lmruby -lbiext -lbi -lglew32 -lopengl32 -lws2_32 -static-libstdc++ -static-libgcc"

  CFLAGS="-std=gnu++11 -O3 -Wall -DNDEBUG `#{SDL2_CONFIG} --cflags`"
  LDFLAGS="`#{SDL2_CONFIG} --libs` -lSDL2_image -lSDL2_mixer"

  def self.available?
    `type x86_64-w64-mingw32-gcc > /dev/null 2>&1`
    $?.success?
  end

  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -o #{outfile} #{sources.join(" ")} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS}"
    puts cmd
    system cmd
  end
end

class Emscripten < Compiler
  CC="em++"
  INCLUDE_PATHS="-I #{BISDK_DIR}/build/emscripten/include"
  LIB_PATHS="-L #{BISDK_DIR}/build/emscripten/lib"
  LIBS="-lmruby -lbiext -lbi"

  EM_LIB_FLAGS="-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png]"
  EM_MEMORY_FLAGS="-s ALLOW_MEMORY_GROWTH=1 -s TOTAL_MEMORY=1024Mb -s WASM_MEM_MAX=1024Mb"
  EM_FLAGS="-s WASM=1 #{EM_LIB_FLAGS} #{EM_MEMORY_FLAGS} -s FETCH=1 -s DISABLE_EXCEPTION_CATCHING=0"
  EM_CFLAGS=ENV['EM_CFLAGS']
  EM_LDFLAGS=ENV['EM_LDFLAGS']

  CFLAGS="-std=gnu++11 -DNDEBUG -Oz -Wall #{EM_CFLAGS}"
  LDFLAGS="#{EM_LDFLAGS}"

  def self.available?
    `type emcc > /dev/null 2>&1`
    $?.success?
  end
  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -o #{outfile} #{sources.join(" ")} #{EM_FLAGS} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS}"
    puts cmd
    system cmd
  end
end

#
#
#
PLATFORM=ARGV.shift
DST_FILE=ARGV.pop
IN_FILES=ARGV

case PLATFORM
when 'host'
  if /darwin/ === RbConfig::CONFIG['host_os']
    MacOS::compile(IN_FILES,DST_FILE)
  else
    Linux::compile(IN_FILES,DST_FILE)
  end
when 'macos'
  MacOS::compile(IN_FILES,DST_FILE)
when 'linux'
  Linux::compile(IN_FILES,DST_FILE)
when 'mingw'
  Mingw::compile(IN_FILES,DST_FILE) if Mingw::available?
when 'emscripten'
  Emscripten::compile(IN_FILES,DST_FILE) if Emscripten::available?
end
