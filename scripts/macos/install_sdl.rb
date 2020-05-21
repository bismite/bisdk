#!/usr/bin/env ruby
require "fileutils"
begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :red :to_s
    alias :green :to_s
  end
end


SDL2_FRAMEWORK = "SDL2.framework"
SDL2_DMG = "SDL2-2.0.12.dmg"

FRAMEWORKS_DIR = "build/macos/Frameworks"
LIB_DIR = "build/macos/lib"
INCLUDE_DIR = "build/macos/include"
BIN_DIR = "build/macos/bin"
DOWNLOAD_DIR = "build/download"

FileUtils.mkdir_p FRAMEWORKS_DIR
FileUtils.mkdir_p LIB_DIR
FileUtils.mkdir_p INCLUDE_DIR
FileUtils.mkdir_p BIN_DIR
FileUtils.mkdir_p "build/licenses/macos/hidapi"

def run(cmd)
  puts cmd.green
  system cmd
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
end

unless File.exists? "#{FRAMEWORKS_DIR}/#{SDL2_FRAMEWORK}"
  run "hdiutil attach #{DOWNLOAD_DIR}/#{SDL2_DMG}"
  run "cp -R /Volumes/SDL2/#{SDL2_FRAMEWORK} #{FRAMEWORKS_DIR}"
  run "hdiutil detach /Volumes/SDL2"
end

dir = "#{FRAMEWORKS_DIR}/#{SDL2_FRAMEWORK}"
dylib_name = "libSDL2-2.0.0.dylib"
sdl2_dylib = "#{LIB_DIR}/#{dylib_name}"
lib_name="#{Dir.pwd}/#{LIB_DIR}/#{dylib_name}"

# copy files
run "cp #{dir}/Versions/A/SDL2 #{sdl2_dylib}"
run "(cd #{LIB_DIR}; ln -sf #{dylib_name} libSDL2.dylib )"
run "rsync -av #{dir}/Versions/A/Headers/ #{INCLUDE_DIR}/SDL2"
run "cp #{dir}/Versions/A/Frameworks/hidapi.framework/Versions/A/hidapi '#{Dir.pwd}/build/macos/lib/libhidapi.dylib'"

# update link
run "install_name_tool -id #{lib_name} #{sdl2_dylib}"
run "codesign --remove-signature #{sdl2_dylib}"
run "install_name_tool -id '#{Dir.pwd}/build/macos/lib/libhidapi.dylib' build/macos/lib/libhidapi.dylib"
run "install_name_tool -change '@rpath/hidapi.framework/Versions/A/hidapi' '#{Dir.pwd}/build/macos/lib/libhidapi.dylib' '#{sdl2_dylib}'"
run "codesign --remove-signature build/macos/lib/libhidapi.dylib"

run "otool -L #{sdl2_dylib}"
run "otool -L build/macos/lib/libhidapi.dylib"

# sdl2-config dummy
run "cp -f src/sdl2-config.rb #{BIN_DIR}/sdl2-config"
run "chmod +x #{BIN_DIR}/sdl2-config"
