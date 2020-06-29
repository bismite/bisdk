#!/usr/bin/env ruby
require 'optparse'
require_relative "lib/utils"

targets = {}
ARGV.each{|arg|
  case arg
  when /linux/
    targets["linux"] = true if /linux/ === RUBY_PLATFORM
  when /macos/
    targets["macos"] = true  if /darwin/ === RUBY_PLATFORM
  when /emscripten/
    targets["emscripten"] = true if which "emcc"
  when /mingw/
    targets["x86_64-w64-mingw32"] = true if which "x86_64-w64-mingw32-gcc"
  end
}
targets = targets.keys

puts "targets: #{targets}"


run "./scripts/download_required_files.rb #{targets.join(' ')}"
run "./scripts/copy_bilibs.rb"

run "tar zxf build/download/#{MRUBY}.tar.gz -C build/"

def spawn(cmd, target, logfile)
  rout, wout = IO.pipe
  rerr, werr = IO.pipe
  pid = Process.spawn cmd, [:out,:err] => [logfile,"a"]
  _, status = Process.wait2(pid)
  exit unless status.success?
end


FileUtils.mkdir_p "tmp"
timestamp = Time.now.strftime "%Y%m%d-%H%M%S"
pids = %w(linux emscripten x86_64-w64-mingw32).map{|target|
  # logfile = File.join "tmp", "#{target}-#{timestamp}.log"
  logfile = File.join "tmp", "#{target}.log"
  Process.fork do
    %w(
      ./scripts/build_bilibs.rb
      ./scripts/build_mruby.rb
      ./scripts/licenses.rb
      ./scripts/build_bitool.rb
      ./scripts/build_template.rb
    ).each{|script|
      spawn "#{script} #{target}", target, logfile
    }
    puts "#{target} done."
  end
}

pids.each{|pid| Process.wait pid }
