#!/usr/bin/env ruby
require_relative "../lib/utils"

BINS = %w(bicompile birun mirb mrbc mruby mruby-strip)
LIBS = %w(libSDL2-2.0.0.dylib libSDL2_image-2.0.0.dylib libSDL2_mixer-2.0.0.dylib libmpg123.0.dylib libGLEW.2.1.0.dylib)

cp_r "src/bismite-sdk.app", "build/macos"

root = File.absolute_path(File.join( File.dirname(File.expand_path(__FILE__)), "../.." ))
app_path = "#{root}/build/macos/bismite-sdk.app/Contents/Resources"

mkdir_p "#{app_path}/lib"
mkdir_p "#{app_path}/include"
mkdir_p "#{app_path}/bin"

MACOS_DYLIBS.each{|dylib|
  next unless File.exists? "build/macos/lib/#{dylib}"
  cp "build/macos/lib/#{dylib}", "#{app_path}/lib"
}

BINS.each{|bin|
  next unless File.exists? "build/macos/bin/#{bin}"
  cp "build/macos/bin/#{bin}", "#{app_path}/bin"
}

%w(bi GL mruby SDL2).each{|header|
  cp_r "build/macos/include/#{header}", "#{app_path}/include/"
}

run "./scripts/macos/update_install_name.rb build/macos/bismite-sdk.app"
