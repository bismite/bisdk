#!/usr/bin/env ruby
require_relative "../lib/utils"

ENV['PATH']="/Users/k2/git/bismite/bisdk/build/macos/bin:" + ENV['PATH']

PREFIX="#{Dir.pwd}/build/macos"
DOWNLOAD_DIR = "build/download"

# for SDL2_mixer searching mpg123
ENV['C_INCLUDE_PATH']="#{PREFIX}/include"
ENV['LIBRARY_PATH']="#{PREFIX}/lib"
ENV['LD_LIBRARY_PATH']="#{PREFIX}/lib"

DISABLE_FEATURES = %w(
  sdltest
  bmp
  gif
  jpg
  lbm
  pcx
  pnm
  svg
  tga
  tif
  xcf
  xpm
  xv
  webp
  music-mod
  music-midi
  music-ogg
  music-flac
  music-opus
).map{|d| "--disable-#{d}" }.join(" ")

[
  %w( mpg123-1.25.13 .tar.bz2 libmpg123.0.dylib ) ,
  %w( SDL2_image-2.0.5 .tar.gz libSDL2_image-2.0.0.dylib ),
  %w( SDL2_mixer-2.0.4 .tar.gz libSDL2_mixer-2.0.0.dylib ),
].each{|name,ext,lib|
  if File.exists? "build/macos/lib/#{lib}"
    puts "build/macos/lib/#{lib} has been compiled."
    next
  end
  zip = name+ext
  if ext.end_with? "bz2"
    run "tar jxf #{DOWNLOAD_DIR}/#{zip} -C build/macos"
  else
    run "tar zxf #{DOWNLOAD_DIR}/#{zip} -C build/macos"
  end

  # compile
  run "(cd build/macos/#{name}; env; ./configure --prefix=#{PREFIX} #{DISABLE_FEATURES}; make clean all install)"
}
