#!/usr/bin/env ruby
require "fileutils"
begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :red :to_s
    alias :green :to_s
  end
end

ENV['PATH']="/Users/k2/git/bismite/bisdk/build/macos/bin:" + ENV['PATH']

PREFIX="#{Dir.pwd}/build/macos"
DOWNLOAD_DIR = "build/download"

FileUtils.mkdir_p DOWNLOAD_DIR

# for SDL2_mixer searching mpg123
ENV['C_INCLUDE_PATH']="#{PREFIX}/include"
ENV['LIBRARY_PATH']="#{PREFIX}/lib"
ENV['LD_LIBRARY_PATH']="#{PREFIX}/lib"

def run(cmd)
  puts cmd.green
  system cmd
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
end

[
  %w( https://mpg123.de/download/ mpg123-1.25.13 .tar.bz2 libmpg123.0.dylib) ,
  %w( https://www.libsdl.org/projects/SDL_image/release/ SDL2_image-2.0.5 .tar.gz libSDL2_image-2.0.0.dylib),
  %w( https://www.libsdl.org/projects/SDL_mixer/release/ SDL2_mixer-2.0.4 .tar.gz libSDL2_mixer-2.0.0.dylib),
].each{|server,name,ext,lib|
  if File.exists? "build/macos/lib/#{lib}"
    puts "build/macos/lib/#{lib} has been compiled."
    next
  end
  url = server+name+ext
  zip = name+ext
  # "-C -" continue download
  run "curl --progress-bar -S -L -C - -o #{DOWNLOAD_DIR}/#{zip} #{url}"
  if ext.end_with? "bz2"
    run "tar jxf #{DOWNLOAD_DIR}/#{zip} -C build/macos"
  else
    run "tar zxf #{DOWNLOAD_DIR}/#{zip} -C build/macos"
  end

  # compile
  run "(cd build/macos/#{name}; env; ./configure --prefix=#{PREFIX} --disable-sdltest; make clean all install)"
}
