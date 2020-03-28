#!/usr/bin/env ruby
begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :yellow :to_s
    alias :red :to_s
  end
end

def run(script)
  puts " * * * #{script}".yellow
  system script
  unless $?.success?
    puts "exit status fail.".red
    exit 1
  end
end

run "./scripts/build_bilibs.sh"
run "./scripts/build_mruby.sh"
run "./scripts/licenses.sh"
run "./scripts/build_bitool.rb"
run "./scripts/build_template.sh"
