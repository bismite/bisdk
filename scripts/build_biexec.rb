#!/usr/bin/env ruby
require "fileutils"
begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :yellow :to_s
    alias :red :to_s
  end
end

BISDK_DIR=File.absolute_path(File.join(File.dirname(__FILE__),".."))

class Compiler
  MRB_FLAGS="-DMRB_INT64 -DMRB_UTF8_STRING"
end

def run(cmd)
  puts cmd.yellow
  system cmd
  unless $?.success?
    puts "failed #{cmd}".red
    exit 1
  end
end

class MacOS < Compiler
  HOST = "macos"
  CC = "clang"
  INCLUDE_PATHS = "-I #{BISDK_DIR}/build/#{HOST}/include -I #{BISDK_DIR}/build/#{HOST}/include/SDL2"
  LIB_PATHS="-L #{BISDK_DIR}/build/#{HOST}/lib"

  LIBS="-lSDL2 -lSDL2_image -lSDL2_mixer -lmpg123 -lmruby -lbiext -lbi -lGLEW -lstdc++"
  FRAMEWORKS="-framework OpenGL"
  CFLAGS="-std=gnu11 -Os -Wall -DNDEBUG"
  LDFLAGS="#{FRAMEWORKS}"

  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -o #{outfile} #{sources.join(" ")} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS}"
    run cmd
  end
end

class Linux < Compiler
  HOST =  "linux"
  CC = "clang"
  INCLUDE_PATHS = "-I #{BISDK_DIR}/build/#{HOST}/include"
  LIB_PATHS="-L #{BISDK_DIR}/build/#{HOST}/lib"
  LIBS="-lmruby -lbiext -lbi -lGLEW -lm -lGL -ldl"
  CFLAGS="-std=gnu11 -Os -Wall -DNDEBUG `sdl2-config --cflags`"
  LDFLAGS="`sdl2-config --libs` -lSDL2_image -lSDL2_mixer"

  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -o #{outfile} #{sources.join(" ")} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS}"
    run cmd
  end
end

class Mingw < Compiler
  CC="x86_64-w64-mingw32-gcc"

  SDL2_CONFIG="#{BISDK_DIR}/build/x86_64-w64-mingw32/bin/sdl2-config"
  INCLUDE_PATHS="-I #{BISDK_DIR}/build/x86_64-w64-mingw32/include"
  LIB_PATHS="-L #{BISDK_DIR}/build/x86_64-w64-mingw32/lib"

  LIBS="-lmruby -lbiext -lbi -lglew32 -lopengl32 -lws2_32 -static-libgcc"

  CFLAGS="-std=gnu11 -Os -Wall -DNDEBUG `#{SDL2_CONFIG} --cflags`"
  LDFLAGS="`#{SDL2_CONFIG} --libs` -lSDL2_image -lSDL2_mixer -llibdl"

  def self.available?
    `type x86_64-w64-mingw32-gcc > /dev/null 2>&1`
    $?.success?
  end

  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -o #{outfile} #{sources.join(" ")} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS}"
    run cmd
  end
end

class Emscripten < Compiler
  CC="emcc"
  INCLUDE_PATHS="-I #{BISDK_DIR}/build/emscripten/include"
  LIB_PATHS="-L #{BISDK_DIR}/build/emscripten/lib"
  LIBS="-lmruby -lbiext -lbi"

  EM_LIB_FLAGS="-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png]"
  EM_MEMORY_FLAGS="-s ALLOW_MEMORY_GROWTH=1 -s INITIAL_MEMORY=128Mb -s MAXIMUM_MEMORY=1024Mb"
  EM_FLAGS="#{EM_LIB_FLAGS} #{EM_MEMORY_FLAGS} -s DISABLE_EXCEPTION_CATCHING=0 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -flto=full"
  EM_CFLAGS=ENV['EM_CFLAGS']
  EM_LDFLAGS=ENV['EM_LDFLAGS']

  CFLAGS="-std=gnu11 -DNDEBUG -Os -Wall #{EM_CFLAGS}"
  LDFLAGS="#{EM_LDFLAGS}"

  SHELL="--shell-file src/shell/shell_bisdk.html"

  def self.available?
    `type emcc > /dev/null 2>&1`
    $?.success?
  end
  def self.compile(sources,outfile)
    FileUtils.mkdir_p File.dirname(outfile)
    cmd = "#{CC} -v -o #{outfile} #{sources.join(" ")} #{self.target} #{EM_FLAGS} #{CFLAGS} #{INCLUDE_PATHS} #{MRB_FLAGS} #{LIB_PATHS} #{LIBS} #{LDFLAGS} #{SHELL}"
    run cmd
  end
end

class Wasm < Emscripten
  def self.target
    "-s WASM=1"
  end
end

class WasmDL < Emscripten
  def self.target
    # "-s WASM=1 -s MAIN_MODULE=2 -s 'EXPORTED_FUNCTIONS=[\"_main\"]'"
    "-s WASM=1 -s MAIN_MODULE=1"
  end
end

class Js < Emscripten
  def self.target
    "-s WASM=0"
  end
end

class JsDL < Emscripten
  def self.target
    "-s WASM=0 -s MAIN_MODULE=1"
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
when 'wasm'
  Wasm::compile(IN_FILES,DST_FILE) if Wasm::available?
when 'wasm-dl'
  WasmDL::compile(IN_FILES,DST_FILE) if WasmDL::available?
when 'js'
  Js::compile(IN_FILES,DST_FILE) if Js::available?
when 'js-dl'
  JsDL::compile(IN_FILES,DST_FILE) if JsDL::available?
end
