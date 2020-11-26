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
    puts "#{path} download failed MD5 mismatch #{hash}".red
    exit 1
  end
end

def download(files,target)
  files.each_slice(2) do |file,hash|
    if file.is_a? Array
      url,filename = file
    else
      url = file
      filename = File.basename url
    end
    filepath = "build/download/#{target}/#{filename}"
    if check filepath,hash
      puts "already downloaded #{filepath}"
    else
      run "curl -JL#S -o #{filepath} #{url}"
      check! filepath,hash
    end
  end
end

files = YAML.load File.read("scripts/required_files.yml")
ARGV.each{|target|
  FileUtils.mkdir_p "build/download/#{target}"
  download files[target], target
}
