#!/usr/bin/env ruby
require_relative "lib/utils"

TARGET = ARGV.first
DIR = "build/#{TARGET}"
BI_CORE_DIR="#{DIR}/bismite-library-core"
BI_EXT_DIR="#{DIR}/bismite-library-ext"

unless Dir.exists? BI_CORE_DIR
  if ENV["BI_CORE"]
    puts "bismite-core library copy from #{ENV["BI_CORE"]}"
    FileUtils.mkdir_p BI_CORE_DIR
    FileUtils.cp_r File.join(ENV["BI_CORE"],"/."), BI_CORE_DIR
    FileUtils.rm_rf "#{BI_CORE_DIR}/build"
  else
    run "unzip build/download/#{TARGET}/bismite-library-core.zip -d #{DIR}"
    run "mv #{DIR}/bismite-library-core-master #{DIR}/bismite-library-core"
  end
end

unless Dir.exists? BI_EXT_DIR
  if ENV["BI_EXT"]
    puts "bismite-ext library copy from #{ENV["BI_EXT"]}"
    FileUtils.mkdir_p BI_EXT_DIR
    FileUtils.cp_r File.join(ENV["BI_EXT"],"/."), BI_EXT_DIR
    FileUtils.rm_rf "#{BI_EXT_DIR}/build"
  else
    run "unzip build/download/#{TARGET}/bismite-library-ext.zip -d #{DIR}"
    run "mv #{DIR}/bismite-library-ext-master #{DIR}/bismite-library-ext"
  end
end
