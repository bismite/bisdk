#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]
LICENSE_DIR = "build/#{TARGET}/licenses"

FileUtils.mkdir_p LICENSE_DIR

FileUtils.cp "build/bi-core/LICENSE", "#{LICENSE_DIR}/LICENSE.bi-core.txt"
FileUtils.cp "build/bi-ext/LICENSE", "#{LICENSE_DIR}/LICENSE.bi-ext.txt"

case TARGET
when /linux/
  FileUtils.cp "build/#{TARGET}/mruby/host/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"

when /macos/
  FileUtils.cp "build/#{TARGET}/mruby/host/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"
  FileUtils.cp "build/macos/glew-2.1.0/LICENSE.txt", "#{LICENSE_DIR}/LICENSE.glew.txt"
  FileUtils.cp "build/macos/mpg123-1.25.13/COPYING", "#{LICENSE_DIR}/COPYING.mpg123.txt"

when /mingw/
  FileUtils.cp "build/#{TARGET}/mruby/#{TARGET}/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"
  Dir["src/licenses/mingw/*.txt"].each{|f| FileUtils.cp f,LICENSE_DIR }
  FileUtils.cp "build/download/COPYING.MinGW-w64-runtime.txt", LICENSE_DIR
  FileUtils.cp "build/download/COPYING.MinGW-w64.txt", LICENSE_DIR
  # DLL license
  FileUtils.cp "build/x86_64-w64-mingw32/bin/LICENSE.mpg123.txt",LICENSE_DIR

when /emscripten/
  FileUtils.cp "build/#{TARGET}/mruby/#{TARGET}/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"

  EMDIR = File.dirname which "emcc"

  FileUtils.cp "#{EMDIR}/LICENSE", "#{LICENSE_DIR}/LICENSE.emscripten.txt"
  FileUtils.cp "#{EMDIR}/AUTHORS", "#{LICENSE_DIR}/AUTHORS.emscripten.txt"

  FileUtils.cp "#{EMDIR}/system/lib/libunwind/LICENSE.TXT", "#{LICENSE_DIR}/LICENSE.libunwind.txt"
  FileUtils.cp "#{EMDIR}/system/lib/compiler-rt/LICENSE.TXT", "#{LICENSE_DIR}/LICENSE.compiler-rt.txt"
  FileUtils.cp "#{EMDIR}/system/lib/compiler-rt/CREDITS.TXT", "#{LICENSE_DIR}/CREDITS.compiler-rt.txt"
  FileUtils.cp "#{EMDIR}/system/lib/libc/musl/COPYRIGHT", "#{LICENSE_DIR}/COPYRIGHT.musl.txt"
end
