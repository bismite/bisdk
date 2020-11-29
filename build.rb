#!/usr/bin/env ruby
begin
  require "dotenv/load"
rescue LoadError
  nil
end
require 'optparse'
require_relative "scripts/lib/utils"

TARGET = ARGV.first
exit 1 unless TARGET
puts "TARGET: #{TARGET}"
run "./scripts/download_required_files.rb #{TARGET}"
run "./scripts/copy_bilibs.rb #{TARGET}"
FileUtils.mkdir_p "build/#{TARGET}/#{MRUBY}"
run "tar --strip-component 1 -zxf build/download/#{TARGET}/#{MRUBY}.tar.gz -C build/#{TARGET}/#{MRUBY}"

# install libraries
case TARGET
when /macos/
  run "./scripts/macos/install_sdl.rb"
  run "./scripts/macos/install_sdl_image_and_mixer.rb"
  run "./scripts/macos/install_glew_dylib.rb"
when /mingw/
  run "./scripts/mingw/install_sdl.sh"
  run "./scripts/mingw/install_glew.sh"
end

%w(
  ./scripts/build_bilibs.rb
  ./scripts/build_mruby.rb
  ./scripts/licenses.rb
  ./scripts/build_bitool.rb
).each{|script|
  run "#{script} #{TARGET}"
}
