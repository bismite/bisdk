#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]
LICENSE_DIR = "build/#{TARGET}/licenses"

mkdir_p LICENSE_DIR

cp "build/#{TARGET}/bismite-library-core/LICENSE", "#{LICENSE_DIR}/LICENSE.bismite-library-core.txt"
cp "build/#{TARGET}/bismite-library-ext/LICENSE", "#{LICENSE_DIR}/LICENSE.bismite-library-ext.txt"

case TARGET
when /linux/
  cp "build/#{TARGET}/#{MRUBY}/build/host/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"

when /macos/
  cp "build/#{TARGET}/#{MRUBY}/build/host/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"
  cp "build/macos/glew-2.1.0/LICENSE.txt", "#{LICENSE_DIR}/LICENSE.glew.txt"
  cp "build/macos/mpg123-1.25.13/COPYING", "#{LICENSE_DIR}/COPYING.mpg123.txt"

when /mingw/
  cp "build/#{TARGET}/#{MRUBY}/build/#{TARGET}/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"
  Dir["src/licenses/mingw/*.txt"].each{|f| cp f,LICENSE_DIR }
  cp "build/download/#{TARGET}/COPYING.MinGW-w64-runtime.txt", LICENSE_DIR
  cp "build/download/#{TARGET}/COPYING.MinGW-w64.txt", LICENSE_DIR
  # DLL license
  cp "build/x86_64-w64-mingw32/bin/LICENSE.mpg123.txt",LICENSE_DIR

when /emscripten/
  cp "build/#{TARGET}/#{MRUBY}/build/#{TARGET}/LEGAL", "#{LICENSE_DIR}/LEGAL.mruby.txt"

  EMDIR = File.dirname which "emcc"

  cp "#{EMDIR}/LICENSE", "#{LICENSE_DIR}/LICENSE.emscripten.txt"
  cp "#{EMDIR}/AUTHORS", "#{LICENSE_DIR}/AUTHORS.emscripten.txt"

  cp "#{EMDIR}/system/lib/libunwind/LICENSE.TXT", "#{LICENSE_DIR}/LICENSE.libunwind.txt"
  cp "#{EMDIR}/system/lib/compiler-rt/LICENSE.TXT", "#{LICENSE_DIR}/LICENSE.compiler-rt.txt"
  cp "#{EMDIR}/system/lib/compiler-rt/CREDITS.TXT", "#{LICENSE_DIR}/CREDITS.compiler-rt.txt"
  cp "#{EMDIR}/system/lib/libc/musl/COPYRIGHT", "#{LICENSE_DIR}/COPYRIGHT.musl.txt"
end
