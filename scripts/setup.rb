#!/usr/bin/env ruby
require_relative "lib/utils"

# TARGET: linux, macos, x86_64-w64-mingw32, emscripten

TARGET=ARGV[0]

run "./scripts/download_required_files.rb macos mingw"

run "./scripts/build_bilibs.rb #{TARGET}"
run "./scripts/build_mruby.rb #{TARGET}"
run "./scripts/licenses.rb #{TARGET}"

run "./scripts/build_bitool.rb #{TARGET}"

exit

run "./scripts/build_template.sh"
