#!/usr/bin/env ruby
#
# usage: update_install_name.rb /path/to/target/exes exe1 exe2 exe3...
#

require_relative "../lib/utils"


NEW_PATH = "@executable_path"

dir = ARGV.shift
targets = ARGV
targets += MACOS_DYLIBS

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
    list = (`otool -L #{t}`).each_line.drop(1).map{|l| l.match(/(.*) \(.*/)[1].strip }
    # change links
    MACOS_DYLIBS.each{|lib|
      next if lib == t
      original_name = list.find{|l| l.end_with? lib }
      if original_name
        run "install_name_tool -change '#{original_name}' '#{NEW_PATH}/#{lib}' #{t}"
      end
    }
  }

  targets.each{|t| run "otool -L #{t}" }
end
