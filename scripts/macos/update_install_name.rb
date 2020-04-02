#!/usr/bin/env ruby
begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :red :to_s
    alias :green :to_s
  end
end

def run(cmd)
  puts cmd.green
  result = `#{cmd}`
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
  result
end

dir = ARGV.shift
targets = ARGV
new_prefix = "@executable_path"

libs = %w(
  libmpg123.0.dylib
  libSDL2-2.0.0.dylib
  libSDL2_mixer-2.0.0.dylib
  libSDL2_image-2.0.0.dylib
  libhidapi.dylib
)
targets += libs

targets.each{|t|
  # remove debugging symbols
  run "strip -S '#{dir}/#{t}'"
  # rename
  if t.end_with? ".dylib"
    new_name = "#{new_prefix}/#{t}"
    run "install_name_tool -id '#{new_name}' '#{dir}/#{t}'"
  end
  # list of current links
  list = run("otool -L #{dir}/#{t}").each_line.drop(1).map{|l| l.match(/(.*) \(.*/)[1].strip }
  # change links
  libs.each{|lib|
    next if lib == t
    new_name = "#{new_prefix}/#{lib}"
    original_name = list.find{|l| l.end_with? lib }
    if original_name
      run "install_name_tool -change '#{original_name}' '#{new_name}' '#{dir}/#{t}'"
    end
  }
}

targets.each{|t| puts run "otool -L '#{dir}/#{t}'" }
