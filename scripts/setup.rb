#!/usr/bin/env ruby
require_relative "lib/utils"

run "./scripts/download_required_files.rb macos mingw"

run "./scripts/build_bilibs.rb linux"
run "./scripts/build_bilibs.rb mingw"
run "./scripts/build_bilibs.rb emscripten"


run "./scripts/build_mruby.sh"
run "./scripts/licenses.sh"
run "./scripts/build_bitool.rb"
run "./scripts/build_template.sh"
