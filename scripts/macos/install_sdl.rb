#!/usr/bin/env ruby
require "colorize"
require "fileutils"

FRAMEWORKS_DIR = "build/macos/Frameworks"
FileUtils.mkdir_p FRAMEWORKS_DIR

def run(cmd)
  puts cmd.green
  puts `#{cmd}`
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
lib_dir = "build/macos/lib"
dylib_name = "libSDL2-2.0.0.dylib"
dylib = "#{lib_dir}/#{dylib_name}"
lib_name="#{Dir.pwd}/build/macos/lib/#{dylib_name}"
run "cp #{dir}/Versions/A/SDL2 #{dylib}"
run "(cd #{lib_dir}; ln -sf #{dylib_name} libSDL2.dylib )"
run "install_name_tool -id #{lib_name} #{dylib}"
run "codesign --remove-signature #{dylib}"
run "otool -L #{dylib}"
run "rsync -av #{dir}/Versions/A/Headers/ build/macos/include/SDL2"

run "cp -f src/sdl2-config.rb build/macos/bin/sdl2-config"
run "chmod +x build/macos/bin/sdl2-config"
