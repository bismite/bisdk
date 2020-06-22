#!/usr/bin/env ruby
require_relative "lib/utils"

# TARGET: linux, macos, x86_64-w64-mingw32, emscripten

TARGET=ARGV[0]

run "./scripts/download_required_files.rb macos mingw"
run "./scripts/copy_bilibs.rb"

targets = []
targets << ( /linux/ === RUBY_PLATFORM ? "linux" : "macos" )
targets << "emscripten" if which "emcc"
targets << "x86_64-w64-mingw32" if which "x86_64-w64-mingw32-gcc"
puts "targets: #{targets}"

def spawn(cmd, target)
  rout, wout = IO.pipe
  rerr, werr = IO.pipe
  pid = Process.spawn cmd, [:out,:err] => ["#{target}.log","a"]
  _, status = Process.wait2(pid)
  exit unless status.success?
end

pids = %w(linux emscripten x86_64-w64-mingw32).map{|target|
  Process.fork do
    spawn "./scripts/build_bilibs.rb #{target}", target
    spawn "./scripts/build_mruby.rb #{target}", target
    spawn"./scripts/licenses.rb #{target}", target
    spawn "./scripts/build_bitool.rb #{target}", target
    spawn "./scripts/build_template.rb #{target}", target
    puts "#{target} done."
  end
}

pids.each{|pid| Process.wait pid }
