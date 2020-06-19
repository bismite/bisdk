require "fileutils"
require "yaml"
require 'digest'

begin
  require "colorize"
rescue LoadError
  String.class_eval do
    alias :yellow :to_s
    alias :red :to_s
  end
end

def run(cmd)
  puts "#{cmd}".green
  system cmd
  unless $?.success?
    puts "failed #{cmd}".red
    exit 1
  end
end
