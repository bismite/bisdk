#!/usr/bin/env ruby
require_relative "../lib/utils"

# usage: update_install_name.rb target_file

NEW_PATH = "@executable_path"
LIBS = %w(
  libmpg123.0.dylib
  libSDL2-2.0.0.dylib
  libSDL2_mixer-2.0.0.dylib
  libSDL2_image-2.0.0.dylib
  libhidapi.dylib
  libGLEW.2.1.0.dylib
)

dir = File.dirname ARGV[0]
targets = [ File.basename(ARGV[0]) ]
targets += LIBS

puts "targets: #{targets} in #{dir}"
Dir.chdir(dir) do
  targets.each{|t|
    puts "#{t}"
    # remove debugging symbols
    run "strip -S #{t}"
    # change ID
    if t.end_with? ".dylib"
      run "install_name_tool -id '#{NEW_PATH}/#{t}' #{t}"
    end
    # list of current links
    list = (`otool -L #{t}`).each_line.drop(2).map{|l| l.match(/(.*) \(.*/)[1].strip }
    # change links
    LIBS.each{|lib|
      next if lib == t
      original_name = list.find{|l| l.end_with? lib }
      if original_name
        run "install_name_tool -change '#{original_name}' '#{NEW_PATH}/#{lib}' #{t}"
      end
    }
  }

  targets.each{|t| run "otool -L #{t}" }
end
