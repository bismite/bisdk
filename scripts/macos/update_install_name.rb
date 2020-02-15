#!/usr/bin/env ruby

require "colorize"

DIR="build/template/macos/template.app/Contents/Resources"
original_prefix = "#{Dir.pwd}/build/macos/lib"
new_prefix = "@executable_path"

libs = %w(
  libmpg123.0.dylib
  libSDL2-2.0.0.dylib
  libSDL2_mixer-2.0.0.dylib
  libSDL2_image-2.0.0.dylib
)
targets = libs + %w(main)

def run(cmd)
  puts cmd.green
  result = `#{cmd}`
  unless $?.success?
    puts "exit status fail."
    exit 1
  end
  result
end


libs.each{|lib|
  new_name="#{new_prefix}/#{lib}"
  original_name="#{original_prefix}/#{lib}"
  run "install_name_tool -id '#{new_name}' '#{DIR}/#{lib}'"
  run "strip -S '#{DIR}/#{lib}'"
  targets.each{|t|
    run "install_name_tool -change '#{original_name}' '#{new_name}' '#{DIR}/#{t}'"
  }
}

targets.each{|t| puts run "otool -L '#{DIR}/#{t}'" }
