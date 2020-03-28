#!/usr/bin/env ruby
begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :red :to_s
    alias :green :to_s
  end
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

def run(cmd)
  puts cmd.green
  result = `#{cmd}`
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
  result
end

targets.each{|t|
  list = run "otool -L #{dir}/#{t}"
  run "strip -S '#{dir}/#{t}'"
  if t.end_with? ".dylib"
    new_name = "#{new_prefix}/#{t}"
    run "install_name_tool -id '#{new_name}' '#{dir}/#{t}'"
  end
  libs.each{|lib|
    next if lib == t
    new_name = "#{new_prefix}/#{lib}"
    original_name = list.each_line.find{|l| l.include? lib }
    if original_name
      original_name = original_name.strip.split(" (").first
      run "install_name_tool -change '#{original_name}' '#{new_name}' '#{dir}/#{t}'"
    end
  }
}

targets.each{|t| puts run "otool -L '#{dir}/#{t}'" }
