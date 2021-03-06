#!/usr/bin/env ruby
#
# usage: build_template.rb {linux|macos|emscripten|mingw} [path/to/output]
#
require_relative "lib/utils"

TARGET = ARGV[0]
DST_DIR = ARGV[1] || "build/templates"
HOST = (/linux/ === RUBY_PLATFORM ? "linux" : "macos")

def copy_license_files(target,dir)
  mkdir_p dir
  cp_r "build/#{target}/licenses", dir
end

case TARGET
when /linux/
  mkdir_p "#{DST_DIR}/linux"
  run "./build/#{HOST}/bin/bicompile src/main.rb #{DST_DIR}/linux/main.mrb"
  run "./scripts/build_biexec.rb linux src/main.c #{DST_DIR}/linux/main"
  copy_license_files "linux", "#{DST_DIR}/linux/licenses"

when /macos/
  mkdir_p "#{DST_DIR}/macos"
  cp_r "src/template.app", "#{DST_DIR}/macos/"
  resource_dir = "#{DST_DIR}/macos/template.app/Contents/Resources"
  mkdir_p resource_dir
  run "./build/#{HOST}/bin/bicompile src/main.rb #{resource_dir}/main.mrb"
  run "./scripts/build_biexec.rb macos src/main.c #{resource_dir}/main"
  libs = MACOS_DYLIBS.map{|l| "build/macos/lib/#{l}" }
  cp libs, resource_dir
  run "./scripts/macos/update_install_name.rb #{resource_dir} main"
  copy_license_files "macos", "#{DST_DIR}/macos/"

when /mingw/
  mkdir_p "#{DST_DIR}/x86_64-w64-mingw32"
  run "./build/#{HOST}/bin/bicompile src/main.rb #{DST_DIR}/x86_64-w64-mingw32/main.mrb"
  run "./scripts/build_biexec.rb mingw src/main.c #{DST_DIR}/x86_64-w64-mingw32/main"
  libs = MINGW_DLLS.map{|l| "build/x86_64-w64-mingw32/bin/#{l}" }
  cp libs, "#{DST_DIR}/x86_64-w64-mingw32/"
  copy_license_files "x86_64-w64-mingw32", "#{DST_DIR}/x86_64-w64-mingw32/"

when /emscripten/
  %w(wasm js wasm-dl).each{|t|
    run "./build/#{HOST}/bin/bicompile src/main.rb #{DST_DIR}/#{t}/main.mrb"
    run "./scripts/build_biexec.rb #{t} src/main-emscripten.c src/support-emscripten.c #{DST_DIR}/#{t}/index.html"
    empath = File.dirname which "emcc"
    secret = "*" * empath.size
    Dir["#{DST_DIR}/#{t}/*"].each{|f| run "sed -i -e 's@#{empath}@#{secret}@' #{f}" if File.file? f }
    copy_license_files "emscripten", "#{DST_DIR}/#{t}/"
  }
end
