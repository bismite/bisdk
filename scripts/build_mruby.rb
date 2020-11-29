#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]

ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/scripts/mruby_config/#{TARGET}.rb"

#
# build mruby
#
Dir.chdir("build/#{TARGET}/#{MRUBY}"){ run "rake -v" }

#
# install mruby
#
def install_mruby(target,build_name)
  %w(bin include lib).each{|d| mkdir_p "build/#{target}/#{d}/" }
  cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/bin/.", "build/#{target}/bin/" rescue nil
  rm_f "build/#{target}/bin/mruby-config"
  cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/lib/.", "build/#{target}/lib/"
  cp_r "build/#{target}/#{MRUBY}/include/.", "build/#{target}/include/"
  cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/include/.", "build/#{target}/include/" rescue nil
end

if %w(macos linux).include? TARGET
  install_mruby TARGET, "host"
else
  install_mruby TARGET, TARGET
end
