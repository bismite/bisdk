#!/usr/bin/env mruby

# usage: biunpackassets path/to/assets.dat destination/dir/path/ SECRET_HEX

SRC = ARGV[0]
DST = ARGV[1]
SECRET = ARGV[2].to_i(16)

def run(command)
  puts command
  result = `#{command}`
  unless $?.success?
    puts "#{command} failed."
    puts result
    raise
  end
end

def mkdir_p(dst)
  if OS.posix?
    run "mkdir -p #{dst}"
  else
    dst.gsub! "/", "\\"
    run "powershell -c \"mkdir '#{dst}'\""
  end
end

Bi::Archive.fetch(SRC){|dat|
  dat.filenames.each{|f|
    bin = dat.read f, SECRET
    path = File.join(DST,f)
    dir = File.dirname path
    mkdir_p dir
    File.open(path,"wb").write(bin)
  }
}
