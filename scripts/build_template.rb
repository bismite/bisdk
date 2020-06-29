#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]
HOST = (/linux/ === RUBY_PLATFORM ? "linux" : "macos")

FileUtils.mkdir_p "build/template/#{TARGET}"

def copy_license_files(target,dir)
  FileUtils.mkdir_p dir
  FileUtils.cp_r "build/licenses/#{target}/.", dir
end

case TARGET
when /linux/
  run "./build/#{HOST}/bin/bicompile src/main.rb build/template/linux/main.mrb"
  run "./scripts/build_biexec.rb linux src/main.c build/template/linux/main"
  copy_license_files "linux", "build/template/linux/licenses"

when /macos/
  FileUtils.cp_r "src/template.app", "build/template/macos/"
  resource_dir = "build/template/macos/template.app/Contents/Resources"
  FileUtils.mkdir_p resource_dir

  run "./build/#{HOST}/bin/bicompile src/main.rb #{resource_dir}/main.mrb"
  run "./scripts/build_biexec.rb macos src/main.c #{resource_dir}/main"
  copy_license_files "macos", "build/template/macos/licenses"

  libs = %w(
    libSDL2-2.0.0.dylib
    libSDL2_image-2.0.0.dylib
    libSDL2_mixer-2.0.0.dylib
    libmpg123.0.dylib
    libhidapi.dylib
    libGLEW.2.1.0.dylib
  ).map{|l| "build/macos/lib/#{l}" }

  FileUtils.cp libs, resource_dir
  run "./scripts/macos/update_install_name.rb #{resource_dir}/main"

when /mingw/
  run "./build/#{HOST}/bin/bicompile src/main.rb build/template/x86_64-w64-mingw32/main.mrb"
  run "./scripts/build_biexec.rb mingw src/main.c build/template/x86_64-w64-mingw32/main"
  Dir["build/x86_64-w64-mingw32/bin/*.dll"].each{|f| FileUtils.cp f, "build/template/x86_64-w64-mingw32/"}
  copy_license_files "x86_64-w64-mingw32", "build/template/x86_64-w64-mingw32/licenses"

when /emscripten/
  %w(wasm js wasm-dl).each{|t|
    run "./build/#{HOST}/bin/bicompile src/main.rb build/template/#{t}/main.mrb"
    run "./scripts/build_biexec.rb #{t} src/main-emscripten.c src/support-emscripten.c build/template/#{t}/index.html"
    copy_license_files "emscripten", "build/template/#{t}/licenses"
  }
end
