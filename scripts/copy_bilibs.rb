#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV.first
DIR = "build/#{TARGET}"
BI_CORE_DIR="#{DIR}/bismite-library-core"
BI_EXT_DIR="#{DIR}/bismite-library-ext"

unless Dir.exists? BI_CORE_DIR
  mkdir_p BI_CORE_DIR
  if ENV["BI_CORE"]
    puts "bismite-core library copy from #{ENV["BI_CORE"]}"
    cp_r File.join(ENV["BI_CORE"],"/."), BI_CORE_DIR
    rm_rf "#{BI_CORE_DIR}/build"
  else
    run "tar --strip-component 1 -zxf build/download/#{TARGET}/bismite-library-core.tar.gz -C #{BI_CORE_DIR}"
  end
end

unless Dir.exists? BI_EXT_DIR
  mkdir_p BI_EXT_DIR
  if ENV["BI_EXT"]
    puts "bismite-ext library copy from #{ENV["BI_EXT"]}"
    cp_r File.join(ENV["BI_EXT"],"/."), BI_EXT_DIR
    rm_rf "#{BI_EXT_DIR}/build"
  else
    run "tar --strip-component 1 -zxf build/download/#{TARGET}/bismite-library-ext.tar.gz -C #{BI_EXT_DIR}"
  end
end
