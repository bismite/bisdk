#!/usr/bin/env mruby

# usage: birun.rb foobar.rb

infile = ARGV[0]

code = `bicompile.rb #{infile} -`

if $? == 0
  IO.popen("mruby -b","w"){|run| run.write code }
else
  puts code
end
