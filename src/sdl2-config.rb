#!/usr/bin/env ruby
require 'optparse'

prefix = File.absolute_path File.join(File.dirname(__FILE__), "../")

opts = OptionParser.new

opts.on("--cflags"){|v| puts "-I#{prefix}/include/SDL2  -D_THREAD_SAFE" }
opts.on("--libs"){|v| puts "-L#{prefix}/lib  -lSDL2" }
opts.on("--prefix"){|v| puts prefix }
opts.on("--version"){|v| puts "2.0.10" }

if ARGV.empty?
  puts opts.help
end

opts.parse!(ARGV)
