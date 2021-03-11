#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]

FileUtils.mkdir_p "build/#{TARGET}/#{MRUBY}"
run "tar --strip-component 1 -zxf build/download/#{TARGET}/#{MRUBY}.tar.gz -C build/#{TARGET}/#{MRUBY}"


ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/scripts/mruby_config/#{TARGET}.rb"

#
# build mruby
#
Dir.chdir("build/#{TARGET}/#{MRUBY}"){ run "rake" }

#
# install mruby
#
def install_mruby(target,build_name)
  prefix = install_path(target)
  %w(bin include lib).each{|d| mkdir_p "build/#{target}/#{d}/" }
  cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/bin/.", "#{prefix}/bin/" rescue nil
  # rm_f "build/#{target}/bin/mruby-config"
  cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/lib/.", "#{prefix}/lib/"
  cp_r "build/#{target}/#{MRUBY}/include/.", "#{prefix}/include/"
  cp_r "build/#{target}/#{MRUBY}/build/#{build_name}/include/.", "#{prefix}/include/" rescue nil
end

if %w(macos linux).include? TARGET
  install_mruby TARGET, "host"
else
  install_mruby TARGET, TARGET
end
