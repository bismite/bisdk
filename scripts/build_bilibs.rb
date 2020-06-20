#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET=ARGV[0]
BI_BUILDER_ROOT = Dir.pwd

BI_CORE_DIR="build/bi-core"
BI_EXT_DIR="build/bi-ext"

#
# install libraries
#
case TARGET
when /macos/
  run "./scripts/macos/install_sdl.rb"
  run "./scripts/macos/install_sdl_image_and_mixer.rb"
  run "./scripts/macos/install_glew.sh"
when /mingw/
  run "./scripts/mingw/install_sdl.sh"
  run "./scripts/mingw/install_glew.sh"
  run "./scripts/mingw/install_dlfcn.sh"
end

#
# download bi-core and bi-ext
#
unless Dir.exists? BI_CORE_DIR
  if ENV["BI_CORE"]
    FileUtils.cp_r ENV["BI_CORE"], "build/"
    FileUtils.rm_rf "#{BI_CORE_DIR}/build"
  else
    run "git clone https://github.com/bismite/bi-core.git #{BI_CORE_DIR}"
  end
end

unless Dir.exists? BI_EXT_DIR
  if ENV["BI_EXT"]
    FileUtils.cp_r ENV["BI_EXT"], "build/"
    FileUtils.rm_rf "#{BI_EXT_DIR}/build"
  else
    run "git clone https://github.com/bismite/bi-ext.git #{BI_EXT_DIR}"
  end
end

#
# build bi-core and bi-ext
#

def copy_headers(target)
  FileUtils.mkdir_p "#{target}/include"
  FileUtils.cp_r "#{BI_CORE_DIR}/include/.", "#{target}/include"
  FileUtils.cp_r "#{BI_EXT_DIR}/include/.", "#{target}/include"
end

def copy_lib(arch,target)
  FileUtils.mkdir_p "#{target}/lib"
  FileUtils.cp "#{BI_CORE_DIR}/build/#{arch}/libbi.a", "#{target}/lib/"
  FileUtils.cp "#{BI_EXT_DIR}/build/#{arch}/libbiext.a", "#{target}/lib/"
end

INSTALL_PATH = "#{BI_BUILDER_ROOT}/build/#{TARGET}"
INCLUDE_PATHS = "-I #{INSTALL_PATH}/include -I #{INSTALL_PATH}/include/SDL2"
WARN = "-Wall -Werror=implicit-function-declaration"

copy_headers INSTALL_PATH

case TARGET
when /mingw/
  CFLAGS = "-std=c11 -O3 #{WARN} `#{INSTALL_PATH}/bin/sdl2-config --cflags`"
  Dir.chdir(BI_CORE_DIR){ run "make -f Makefile.mingw.mk 'INCLUDE_PATHS=#{INCLUDE_PATHS}' 'CFLAGS=#{CFLAGS}'" }
  Dir.chdir(BI_EXT_DIR){ run "make -f Makefile.mingw.mk 'INCLUDE_PATHS=#{INCLUDE_PATHS}' 'CFLAGS=#{CFLAGS}'" }
  copy_lib "mingw", INSTALL_PATH

when /emscripten/
  CFLAGS = "-std=c11 -Oz #{WARN} -s WASM=1 -s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS=[png] -fPIC"
  Dir.chdir(BI_CORE_DIR){ run "make -f Makefile.emscripten.mk clean all 'INCLUDE_PATHS=#{INCLUDE_PATHS}' 'CFLAGS=#{CFLAGS}'" }
  Dir.chdir(BI_EXT_DIR){ run "make -f Makefile.emscripten.mk clean all 'INCLUDE_PATHS=#{INCLUDE_PATHS}' 'CFLAGS=#{CFLAGS}'" }
  copy_lib TARGET, INSTALL_PATH

else
  Dir.chdir(BI_CORE_DIR){ run "make -f Makefile.#{TARGET}.mk 'INCLUDE_PATHS=#{INCLUDE_PATHS}'" }
  Dir.chdir(BI_EXT_DIR){ run "make -f Makefile.#{TARGET}.mk 'INCLUDE_PATHS=#{INCLUDE_PATHS}'" }
  copy_lib TARGET, INSTALL_PATH
end
