#!/usr/bin/env ruby
#
# usage: update_install_name.rb path/to/app.app
#

require_relative "../lib/utils"

APP_PATH = ARGV.first
BINS = %w(bicompile birun mirb mrbc mruby mruby-strip)
LIBS = %w(libSDL2-2.0.0.dylib libSDL2_image-2.0.0.dylib libSDL2_mixer-2.0.0.dylib libmpg123.0.dylib libGLEW.2.1.0.dylib)

NEW_PATH_PREFIX = "@executable_path/../lib"

def update_install_name(target,lib_names)
  # list of current links
  list = (`otool -L #{target}`).each_line.drop(1).map{|l| l.match(/(.*) \(.*/)[1].strip }
  lib_names.each{|lib_name|
    original_name = list.find{|l| l.end_with? lib_name }
    if original_name
      run "install_name_tool -change '#{original_name}' '#{NEW_PATH_PREFIX}/#{lib_name}' #{target}"
    end
  }
end

BINS.each{|name|
  bin = "#{APP_PATH}/Contents/Resources/bin/#{name}"
  next unless File.exist? bin
  # remove debugging symbols
  run "strip -S #{bin}"
  update_install_name bin,LIBS
  run "otool -L #{bin}"
}

LIBS.each{|name|
  lib = "#{APP_PATH}/Contents/Resources/lib/#{name}"
  # remove debugging symbols
  run "strip -S #{lib}"
  # rename
  run "install_name_tool -id '#{NEW_PATH_PREFIX}/#{name}' #{lib}"
  update_install_name lib,LIBS
  run "otool -L #{lib}"
}
