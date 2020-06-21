#!/usr/bin/env ruby
require_relative "lib/utils"

BI_CORE_DIR="build/bi-core"
BI_EXT_DIR="build/bi-ext"

unless Dir.exists? BI_CORE_DIR
  if ENV["BI_CORE"]
    FileUtils.cp_r ENV["BI_CORE"], "build/"
    FileUtils.rm_rf "#{BI_CORE_DIR}/build"
  else
    run "git clone https://github.com/bismite/bi-core.git #{BI_CORE_DIR}"
  end
end

unless Dir.exists? BI_EXT_DIR
  if ENV["BI_EXT"]
    FileUtils.cp_r ENV["BI_EXT"], "build/"
    FileUtils.rm_rf "#{BI_EXT_DIR}/build"
  else
    run "git clone https://github.com/bismite/bi-ext.git #{BI_EXT_DIR}"
  end
end
