#!/usr/bin/env ruby
require_relative "../lib/utils"

PREFIX = install_path "macos"
DOWNLOAD_DIR = "build/download/macos"

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
  zip = name+ext
  unless Dir.exist? "build/macos/#{name}"
    if ext.end_with? "bz2"
      run "tar jxf #{DOWNLOAD_DIR}/#{zip} -C build/macos"
    else
      run "tar zxf #{DOWNLOAD_DIR}/#{zip} -C build/macos"
    end
    run "(cd build/macos/#{name}; ./configure --prefix=#{PREFIX} #{DISABLE_FEATURES}; make all install)"
  end
}
