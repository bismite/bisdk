#!/usr/bin/env ruby
require "colorize"

ENV['PATH']="/Users/k2/git/bismite/bisdk/build/macos/bin:" + ENV['PATH']

PREFIX="#{Dir.pwd}/build/macos"

# for SDL2_mixer searching mpg123
ENV['C_INCLUDE_PATH']="#{PREFIX}/include"
ENV['LIBRARY_PATH']="#{PREFIX}/lib"

def run(cmd)
  puts cmd.green
  puts `#{cmd}`
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
end

[
  %w( https://mpg123.de/download/ mpg123-1.25.13 .tar.bz2 libmpg123.0.dylib) ,
  %w( https://www.libsdl.org/release/ SDL2-2.0.10 .tar.gz libSDL2-2.0.0.dylib) ,
  %w( https://www.libsdl.org/projects/SDL_mixer/release/ SDL2_mixer-2.0.4 .tar.gz libSDL2_mixer-2.0.0.dylib) ,
  %w( https://www.libsdl.org/projects/SDL_image/release/ SDL2_image-2.0.5 .tar.gz libSDL2_image-2.0.0.dylib)
].each{|server,name,ext,lib|
  if File.exists? "build/macos/lib/#{lib}"
    puts "build/macos/lib/#{lib} has been compiled."
    next
  end
  url = server+name+ext
  zip = name+ext
  # "-C -" continue download
  run "curl --progress-bar -S -L -C - -o build/macos/#{zip} #{url}"
  if ext.end_with? "bz2"
    run "(cd build/macos; tar jxf #{zip})"
  else
    run "(cd build/macos; tar zxf #{zip})"
  end

  # compile
  run "(cd build/macos/#{name}; ./configure --prefix=#{PREFIX}; make clean all install)"
}
