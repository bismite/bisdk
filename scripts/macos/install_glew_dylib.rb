#!/usr/bin/env ruby
require_relative "../lib/utils"

mkdir_p "build/macos/lib"
mkdir_p "build/macos/include"

GLEW_DEST = File.absolute_path install_path "macos"

run "tar zxf build/download/macos/glew-2.1.0.tgz -C build/macos/"
Dir.chdir("build/macos/glew-2.1.0"){
  run "make glew.lib.shared install GLEW_DEST=#{GLEW_DEST}"
}
