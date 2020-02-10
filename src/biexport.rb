#!/usr/bin/env mruby

# usage: biexport.rb {macos|linux|windows|emscripten} MRB_FILE ASSETS_FILE DST_DIR

def compile(src,target)
  if src.end_with? ".rb"
    cmd = "bicompile.rb #{src} #{target}"
    puts cmd
    `#{cmd}`
  elsif src.end_with? ".mrb"
    `cp #{src} #{target}`
  end
end

class Export
  def self.export( target, src, asset_file, dst )
    template_table = %w(
      linux linux
      windows x86_64-w64-mingw32
      emscripten emscripten
    ).each_slice(2).to_h
    template_name = template_table[target]

    name = File.basename(src).split(".").first
    dst = File.join dst,name

    prefix = File.join File.dirname($0), ".."
    template = "#{prefix}/share/bisdk/template/#{template_name}/"
    main_mrb = "#{dst}/main.mrb"
    asset = "#{dst}/assets.dat"

    `mkdir -p #{dst}`
    `cp -R "#{template}/." "#{dst}/."`
    `cp "#{asset_file}" "#{asset}"`
    compile src, main_mrb
  end
end

class MacOS
  def self.export( src, asset_file, dst )
    prefix = File.join File.dirname($0), ".."
    template = "#{prefix}/share/bisdk/template/macos/template.app"
    main_mrb = "#{dst}/template.app/Contents/Resources/main.mrb"
    asset = "#{dst}/template.app/Contents/Resources/assets.dat"

    `mkdir -p #{dst}`
    `cp -R "#{template}" "#{dst}/."`
    `cp "#{asset_file}" "#{asset}"`
    compile src, main_mrb
  end
end

case ARGV[0]
when 'macos'
  MacOS.export ARGV[1], ARGV[2], ARGV[3]
else
  Export.export(*ARGV)
end
