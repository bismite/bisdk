#!/usr/bin/env ruby
require_relative "lib/utils"

def check(path,hash)
  if File.exists?(path) and File.file?(path)
    hash == Digest::MD5.hexdigest(File.read(path))
  else
    false
  end
end

def check!(path,hash)
  unless check(path,hash)
    puts "#{path} download failed.".red
    exit 1
  end
end

def download(files)
  files.each_slice(2) do |file,hash|
    if file.is_a? Array
      url,filename = file
    else
      url = file
      filename = File.basename url
    end
    filepath = "build/download/#{filename}"
    if check filepath,hash
      puts "already downloaded #{filepath}"
    else
      run "curl -JL#S -o #{filepath} #{url}"
      check! filepath,hash
    end
  end
end


FileUtils.mkdir_p "build/download"
files = YAML.load File.read("scripts/required_files.yml")
download files["mruby"]
download files["macos"] if ARGV.include? "macos"
download files["mingw"] if ARGV.include? "mingw"
