#!/usr/bin/env ruby
require "msgpack"
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bipackager [options] path/to/assets assets.dat"
  opts.on("-r", "--replace PATH") do |path|
    options[:replace] = path
  end
end.parse!

dir = ARGV[0]
dat = ARGV[1]
secret = ARGV[2] ? ARGV[2].to_i(16) : rand(0xFF)

puts "package #{dir} to #{dat}. secret: 0x#{secret.to_s(16)}"

files = []
list = []
start = 0

Dir.glob("#{dir}/**/*") do |f|
  next unless File.file?(f)
  size = File.size(f)
  files << f
  if options[:replace]
    f = f.gsub dir, options[:replace]
  end
  list << [f,start,size]
  start += size
end

File.open(dat,'wb') do |out|
  index = list.to_msgpack
  out.write [0].pack('V') # 32bit unsigned Little Endian
  out.write [index.size].pack('V') # 32bit unsigned Little Endian
  out.write index

  files.each.with_index do |f,i|
    puts "#{f} -> #{list[i]}"
    buf = File.read( f, encoding:"ASCII-8BIT" )
    converted = buf.each_byte.map{|c| c ^ secret }.pack("C*")
    out.write converted
  end
end
