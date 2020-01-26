#!/usr/bin/env mruby

# usage: biexport.rb {macos|mingw|emscripten} MRB_FILE ASSETS_FILE DST_DIR

class Mingw
  def self.export( mrb_file, asset_file, dst )
    prefix = File.join File.dirname($0), ".."
    template = "#{prefix}/share/bisdk/template/x86_64-w64-mingw32/"
    main_mrb = "#{dst}/main.mrb"
    asset = "#{dst}/assets.dat"

    `mkdir -p #{dst}`
    `cp -R "#{template}/." "#{dst}/."`
    `cp "#{mrb_file}" "#{main_mrb}"`
    `cp "#{asset_file}" "#{asset}"`
  end
end

class Emscripten
  def self.export( mrb_file, asset_file, dst )
    prefix = File.join File.dirname($0), ".."
    template = "#{prefix}/share/bisdk/template/emscripten/"
    main_mrb = "#{dst}/main.mrb"
    asset = "#{dst}/assets.dat"

    `mkdir -p #{dst}`
    `cp -R "#{template}/." "#{dst}/."`
    `cp "#{mrb_file}" "#{main_mrb}"`
    `cp "#{asset_file}" "#{asset}"`
  end
end

class MacOS
  def self.export( mrb_file, asset_file, dst )
    prefix = File.join File.dirname($0), ".."
    template = "#{prefix}/share/bisdk/template/macos/template.app"
    main_mrb = "#{dst}/template.app/Contents/Resources/main.mrb"
    asset = "#{dst}/template.app/Contents/Resources/assets.dat"

    `mkdir -p #{dst}`
    `cp -R "#{template}" "#{dst}/."`
    `cp "#{mrb_file}" "#{main_mrb}"`
    `cp "#{asset_file}" "#{asset}"`
  end
end


case ARGV[0]
when 'macos'
  MacOS.export ARGV[1], ARGV[2], ARGV[3]
when 'mingw'
  Mingw.export ARGV[1], ARGV[2], ARGV[3]
when 'emscripten'
  Emscripten.export ARGV[1], ARGV[2], ARGV[3]
end
