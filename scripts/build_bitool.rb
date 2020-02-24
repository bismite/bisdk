#!/usr/bin/env ruby
require "fileutils"
begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :green :to_s
    alias :red :to_s
  end
end

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end

def run(cmd)
  puts "#{cmd}".green
  system cmd
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
end


DIR = "build/tools"
FileUtils.mkdir_p DIR
%w( bicompile.c birun.c bitool.h bitool.rb ).each{|f| FileUtils.copy "src/bitool/#{f}", DIR }

run "mrbc -B bitool_rb -o #{DIR}/bitool_rb.h #{DIR}/bitool.rb"

class MacOS
  def self.compile
    %w(bicompile birun).each{|name|
      outfile = "build/macos/bin/#{name}"
      cmd = "clang -std=c11 -Wall #{DIR}/#{name}.c -o #{outfile}"
      cmd << " -I build/macos/include -I build/macos/include/SDL2"
      cmd << " -L build/macos/lib -lmruby -lbi -lbiext -lSDL2 -lSDL2_mixer -lSDL2_image"
      cmd << " -lGLEW -framework OpenGL"
      run cmd
    }
  end
end

class Mingw
  SDL2_CONFIG = "build/x86_64-w64-mingw32/bin/sdl2-config"
  MRB_FLAGS = "-DMRB_INT64 -DMRB_UTF8_STRING"
  LIBS="-lmruby -lbiext -lbi -lglew32 -lopengl32 -lws2_32 -static-libstdc++ -static-libgcc"
  def self.compile
    %w(birun bicompile).each{|name|
      outfile = "build/x86_64-w64-mingw32/bin/#{name}.exe"
      cmd = "x86_64-w64-mingw32-g++ -o #{outfile} #{DIR}/#{name}.c"
      cmd << " -O3 -Wall -DNDEBUG -std=gnu++11 "
      cmd << " `#{SDL2_CONFIG} --cflags`"
      cmd << " #{MRB_FLAGS}"
      cmd << " -I build/x86_64-w64-mingw32/include"
      cmd << " -L build/x86_64-w64-mingw32/lib"
      cmd << " #{LIBS}"
      cmd << " `#{SDL2_CONFIG} --libs` -lSDL2_mixer -lSDL2_image -mconsole"
      run cmd
    }
  end
end

PLATFORM = RUBY_PLATFORM =~ /darwin/ ? "macos" : "linux"

if PLATFORM == "macos"
  MacOS.compile
else
  linux
end

if which "x86_64-w64-mingw32-gcc"
  Mingw.compile
end
