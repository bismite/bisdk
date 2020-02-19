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

FRAMEWORKS_DIR = "build/macos/Frameworks"
LIB_DIR = "build/macos/lib"
INCLUDE_DIR = "build/macos/include"
BIN_DIR = "build/macos/bin"
FileUtils.mkdir_p FRAMEWORKS_DIR
FileUtils.mkdir_p LIB_DIR
FileUtils.mkdir_p INCLUDE_DIR
FileUtils.mkdir_p BIN_DIR

def run(cmd)
  puts cmd.green
  system cmd
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
end

SDL2_FRAMEWORK = "SDL2.framework"
SDL2_DMG = "SDL2-2.0.10.dmg"

run "curl --progress-bar -S -L -C - -o build/macos/#{SDL2_DMG} https://www.libsdl.org/release/#{SDL2_DMG}"

unless File.exists? "#{FRAMEWORKS_DIR}/#{SDL2_FRAMEWORK}"
  run "hdiutil attach build/macos/#{SDL2_DMG}"
  run "cp -R /Volumes/SDL2/#{SDL2_FRAMEWORK} #{FRAMEWORKS_DIR}"
  run "hdiutil detach /Volumes/SDL2"
end

dir = "#{FRAMEWORKS_DIR}/#{SDL2_FRAMEWORK}"
dylib_name = "libSDL2-2.0.0.dylib"
dylib = "#{LIB_DIR}/#{dylib_name}"
lib_name="#{Dir.pwd}/#{LIB_DIR}/#{dylib_name}"
run "cp #{dir}/Versions/A/SDL2 #{dylib}"
run "(cd #{LIB_DIR}; ln -sf #{dylib_name} libSDL2.dylib )"
run "install_name_tool -id #{lib_name} #{dylib}"
run "codesign --remove-signature #{dylib}"
run "otool -L #{dylib}"
run "rsync -av #{dir}/Versions/A/Headers/ #{INCLUDE_DIR}/SDL2"

run "cp -f src/sdl2-config.rb #{BIN_DIR}/sdl2-config"
run "chmod +x #{BIN_DIR}/sdl2-config"
