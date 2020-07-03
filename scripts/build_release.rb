#!/usr/bin/env ruby
#
# usage: build_release.rb {macos|linux|x86_64-w64-mingw32} [/path/to/templates/dir] [/path/to/output/dir]
#
require_relative "lib/utils"

TARGET = ARGV[0]
TEMPLATES_DIR = ARGV[1] || "build/templates"
OUTPUT_DIR = ARGV[2] || "build/release/#{TARGET}"
ARCHS = %w( linux macos x86_64-w64-mingw32 js wasm wasm-dl )
BINS = %w(bicompile birun mirb mrbc mruby mruby-strip)

def copy_templates(dir)
  FileUtils.mkdir_p dir
  ARCHS.each{|arch|
    FileUtils.cp_r File.join(TEMPLATES_DIR,arch), dir
  }
end

def copy_bin(dir,ext="")
  FileUtils.mkdir_p dir
  FileUtils.cp BINS.map{|bin| "build/#{TARGET}/bin/#{bin}#{ext}" }, dir
end

def copy_dylibs(dir)
  libs = MACOS_DYLIBS.map{|l| "build/macos/lib/#{l}" }
  FileUtils.cp libs, dir
  run "./scripts/macos/update_install_name.rb #{dir} #{BINS.join(' ')}"
end

def copy_dlls(dir)
  libs = MINGW_DLLS.map{|l| "build/x86_64-w64-mingw32/bin/#{l}" }
  FileUtils.cp libs, dir
end

ext = /mingw/ === TARGET ? ".exe" : ""
copy_bin "#{OUTPUT_DIR}/bismite/bin", ext

copy_dylibs "#{OUTPUT_DIR}/bismite/bin" if /macos/ === TARGET
copy_dlls "#{OUTPUT_DIR}/bismite/bin" if /mingw/ === TARGET

copy_templates "#{OUTPUT_DIR}/bismite/share/bismite/templates"
FileUtils.cp_r "build/#{TARGET}/licenses", "#{OUTPUT_DIR}/bismite/"

%w(
  biexport.rb
  bipackassets.rb
  biunpackassets.rb
).each{|s|
  name = File.basename s, ".rb"
  FileUtils.cp "src/#{s}", "#{OUTPUT_DIR}/bismite/bin/#{name}"
}

Dir.chdir(OUTPUT_DIR){ `zip -r bismite-#{TARGET}.zip bismite` }
