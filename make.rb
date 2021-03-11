#!/usr/bin/env ruby
begin
  require "dotenv/load"
rescue LoadError
  nil
end
require_relative "scripts/lib/utils"

targets = ARGV.reject{|a| not ["clean","macos","linux","emscripten","mingw"].include? a }
if targets.empty?
  if RUBY_PLATFORM.include?("darwin")
    targets << "macos"
  elsif RUBY_PLATFORM.include?("linux")
    targets << "linux"
  end
end

targets.each do |target|

  exit 1 unless ["clean","macos","linux","emscripten","mingw"].include? target

  p install_path target

  if target == "clean"
    run "rm -rf build/macos build/linux build/x86_64-w64-mingw32"
    run "rm -f scripts/mruby_config/*.lock"
    next
  end

  puts "TARGET: #{target}"
  run "./scripts/download_required_files.rb #{target}"
  run "./scripts/copy_bilibs.rb #{target}"

  # install libraries
  case target
  when /macos/
    mkdir_p "build/macos/"
    cp_r "src/bismite-sdk.app", "build/macos"
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
    run "#{script} #{target}"
  }
end
