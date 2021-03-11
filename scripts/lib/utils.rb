require "fileutils"
require "yaml"
require 'digest'

MRUBY = "mruby-3.0.0"

MACOS_DYLIBS = %w(
  libSDL2-2.0.0.dylib
  libSDL2_image-2.0.0.dylib
  libSDL2_mixer-2.0.0.dylib
  libmpg123.0.dylib
  libhidapi.dylib
  libGLEW.2.1.0.dylib
)

MINGW_DLLS = %w(
  glew32.dll
  libmpg123-0.dll
  libpng16-16.dll
  SDL2.dll
  SDL2_image.dll
  SDL2_mixer.dll
  zlib1.dll
)

include FileUtils

begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :yellow :to_s
    alias :red :to_s
    alias :green :to_s
  end
end

def run(cmd)
  puts "#{cmd}".green
  system cmd
  unless $?.success?
    puts "failed #{cmd}".red
    exit 1
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

def install_path(target)
  root = File.absolute_path(File.join( File.dirname(File.expand_path(__FILE__)), "../.." ))
  case target
  when "macos"
    "#{root}/build/macos/bismite-sdk.app/Contents/Resources"
  when "linux","mingw","emscripten"
    "#{root}/build/#{target}"
  else
    raise "target name invalid: #{target}"
  end
end
