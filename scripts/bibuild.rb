#!/usr/bin/env ruby
require "fileutils"

PLATFORM = ARGV.shift
PROJECT_NAME = ARGV.shift
BI_BUILDER_ROOT = ENV['BI_BUILDER_ROOT']
puts "* PLATFORM:#{PLATFORM} PROJECT_NAME:#{PROJECT_NAME} BI_BUILDER_ROOT:#{BI_BUILDER_ROOT}"

TMP_DIR = "build/tmp/#{PLATFORM}/#{PROJECT_NAME}"
TARGET_DIR = "build/#{PLATFORM}/#{PROJECT_NAME}"
FileUtils.mkdir_p [TARGET_DIR, TMP_DIR]

case PLATFORM
when 'host'

  host_os = RbConfig::CONFIG['host_os']
  HOST_OS = case host_os
    when /darwin/; :macos
    when /linux/;  :linux
    else;  host_os.to_sym
  end
  puts "* HOST_OS:#{HOST_OS}"

  CC="/usr/bin/gcc"
  INCLUDE_PATHS="-I #{BI_BUILDER_ROOT}/build/host/include"
  LIB_PATHS="-L #{BI_BUILDER_ROOT}/build/host/lib"
  if HOST_OS == :macos
    LIBS="-lmruby -lbiext -lbi -lGLEW"
    FRAMEWORKS_DIR = "-F #{Dir.home}/Library/Frameworks"
    FRAMEWORKS="-framework SDL2 -framework SDL2_image -framework OpenGL"
    CFLAGS="-std=c11 -O3 -Wall #{FRAMEWORKS_DIR}"
    LDFLAGS="#{FRAMEWORKS_DIR} #{FRAMEWORKS}"
  else
    LIBS="-lmruby -lbiext -lbi -lGLEW -lm -lGL"
    CFLAGS="-std=c11 -O3 -Wall `sdl2-config --cflags`"
    LDFLAGS="`sdl2-config --libs` -lSDL2_image"
  end

when 'mingw'

  `type x86_64-w64-mingw32-gcc > /dev/null 2>&1`
  unless $?.success?
    puts "x86_64-w64-mingw32-gcc not found"
    exit(-1)
  end

  CC="x86_64-w64-mingw32-gcc"
  SDL2_CONFIG="#{BI_BUILDER_ROOT}/build/x86_64-w64-mingw32/bin/sdl2-config"
  INCLUDE_PATHS="-I #{BI_BUILDER_ROOT}/build/x86_64-w64-mingw32/include"
  LIB_PATHS="-L #{BI_BUILDER_ROOT}/build/x86_64-w64-mingw32/lib"
  LIBS="-lmruby -lbiext -lbi -lglew32 -lopengl32 -lws2_32"
  CFLAGS="-std=c11 -O3 -Wall `#{SDL2_CONFIG} --cflags`"
  LDFLAGS="`#{SDL2_CONFIG} --libs` -lSDL2_image"

when 'emscripten'

  `type emcc > /dev/null 2>&1`
  unless $?.success?
    puts "emcc not found"
    exit(-1)
  end

  CC="emcc"
  INCLUDE_PATHS="-I #{BI_BUILDER_ROOT}/build/emscripten/include"
  LIB_PATHS="-L #{BI_BUILDER_ROOT}/build/emscripten/lib"
  LIBS="-lmruby -lbiext -lbi"
  FLAGS="-Oz -Wall -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png]"
  CFLAGS="-std=c11 #{FLAGS}"
  LDFLAGS="#{FLAGS} --preload-file build/assets@assets -s ALLOW_MEMORY_GROWTH=1"

end

#
# compile
#
objects = []
ARGV.each{|src|
  puts "compile #{src}"
  NAME = File.basename src
  obj_name = "#{TMP_DIR}/#{NAME}.o"
  objects << obj_name
  cmd = "#{CC} -c #{src} -o #{obj_name} #{CFLAGS} #{INCLUDE_PATHS}"
  puts cmd
  `#{cmd}`
  exit($?.exitstatus) unless $?.success?
}
objects = objects.join(" ")

case PLATFORM
when 'host'
  `#{CC} #{objects} -o #{TARGET_DIR}/#{PROJECT_NAME}.exe #{LIB_PATHS} #{LIBS} #{LDFLAGS}`

when 'mingw'
  `cp #{BI_BUILDER_ROOT}/build/mingw/bin/*.dll #{TARGET_DIR}/`
  `#{CC} #{objects} -o #{TARGET_DIR}/#{PROJECT_NAME}.exe #{LIB_PATHS} #{LIBS} #{LDFLAGS}`

when 'emscripten'
  `#{CC} #{objects} -o #{TARGET_DIR}/#{PROJECT_NAME}.html #{LIB_PATHS} #{LIBS} #{LDFLAGS}`

end
exit($?.exitstatus) unless $?.success?
