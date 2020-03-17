#!/usr/bin/env mruby

# usage: bipackassets path/to/assets destination/dir/path/ SECRET_HEX

SRC = ARGV[0]
DST = ARGV[1]
SECRET = ARGV[2].to_i(16)

INSTALL_NAME = SRC.end_with? "" "assets"

$start = 0
$files = []
$index = []

def search(dir,parent)
  Dir.entries(dir).each{|f|
    next if f.start_with?(".")
    path = File.join dir,f
    r = if File.directory? path
      search path, File.join(parent,f)
    else
      size = File.size path
      $files << path
      name = File.join "assets",parent,f
      $index << [name,$start,size]
      $start += size
    end
  }
end

search SRC,""

dat = File.join DST, "assets.dat"
File.open(dat,'wb') do |out|
  index = $index.to_msgpack
  index_length = index.bytes.length

  puts index.unpack("C*").map{|c| "%X" % c}.join
  puts "index_length: #{index_length}"

  out.write [0].pack('V') # 32bit unsigned Little Endian
  out.write [index_length].pack('V') # 32bit unsigned Little Endian
  out.write index

  $files.each.with_index do |f,i|
    puts "#{f} -> #{$index[i]}"
    buf = File.open(f,"rb").read
    converted = buf.each_byte.map{|c| c ^ SECRET }.pack("C*")
    out.write converted
  end
end
