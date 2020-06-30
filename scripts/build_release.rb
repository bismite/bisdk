#!/usr/bin/env ruby
#
# usage: build_release.rb {macos|linux|x86_64-w64-mingw32} /path/to/templates/dir /path/to/output/dir
#
require_relative "lib/utils"

TARGET = ARGV[0]
TEMPLATES_DIR = ARGV[1]
OUTPUT_DIR = ARGV[2] || "build/release/#{TARGET}"
ARCHS = %w( linux macos x86_64-w64-mingw32 js wasm wasm-dl )
BINS = %w(bicompile birun mirb mrbc mruby mruby-strip)

def copy_templates(dir)
  FileUtils.mkdir_p dir
  ARCHS.each{|arch|
    FileUtils.cp_r File.join(TEMPLATES_DIR,arch), dir
  }
end

def copy_bin(dir)
  FileUtils.mkdir_p dir
  FileUtils.cp BINS.map{|bin| "build/#{TARGET}/bin/#{bin}" }, dir
end

def copy_dylibs(dir)
  libs = MACOS_DYLIBS.map{|l| "build/macos/lib/#{l}" }
  FileUtils.cp libs, dir
  run "./scripts/macos/update_install_name.rb #{dir} #{BINS.join(' ')}"
end

copy_bin "#{OUTPUT_DIR}/bisdk/bin"
copy_dylibs "#{OUTPUT_DIR}/bisdk/bin" if TARGET == "macos"

copy_templates "#{OUTPUT_DIR}/bisdk/share/bisdk/templates"
FileUtils.cp_r "build/#{TARGET}/licenses", "#{OUTPUT_DIR}/bisdk/"
