#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV[0]

ENV["MRUBY_CONFIG"] = "#{Dir.pwd}/scripts/mruby_config/#{TARGET}.rb"
ENV["MRUBY_BUILD_DIR"] = "#{Dir.pwd}/build/#{TARGET}/mruby"

MRUBY = "mruby-2.1.0"

#
# build mruby
#
run "tar zxf build/download/#{MRUBY}.tar.gz -C build/"
Dir.chdir("build/#{MRUBY}"){ run "rake -v" }

#
# install mruby
#
def install_mruby(target,build_name)
  %w(bin include lib).each{|d| FileUtils.mkdir_p "build/#{target}/#{d}/" }
  bin_src_dir = "build/#{target}/mruby/#{build_name}/bin/."
  if Dir.exists? bin_src_dir
    FileUtils.cp_r bin_src_dir, "build/#{target}/bin/"
    FileUtils.rm_f "build/#{target}/bin/mruby-config"
  end
  FileUtils.cp_r "build/#{target}/mruby/#{build_name}/lib/.", "build/#{target}/lib/"
  FileUtils.cp_r "build/#{MRUBY}/include/.", "build/#{target}/include/"
end

if %w(macos linux).include? TARGET
  install_mruby TARGET, "host"
else
  install_mruby TARGET, TARGET
end
