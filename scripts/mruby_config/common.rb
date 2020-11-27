
BUILD_DIR = File.expand_path File.join __dir__, "..", "..", "build"

def include_gems(conf)

  Dir.glob("#{root}/mrbgems/mruby-*/mrbgem.rake") do |x|
    next if conf.name == "emscripten" and x.include? "mruby-bin-"
    g = File.basename File.dirname x
    conf.gem :core => g unless g =~ /^mruby-(bin-debugger|test)$/
  end

  conf.gem github: 'appPlant/mruby-os'
  conf.gem github: 'iij/mruby-env'
  # conf.gem github: 'iij/mruby-process' # fail in mingw
  if conf.name != "emscripten"
    conf.gem github: 'appPlant/mruby-process' # fail in emscripten module
  end
  conf.gem github: 'ksss/mruby-singleton'
  conf.gem github: 'iij/mruby-dir'
  conf.gem github: 'iij/mruby-iijson'
  # conf.gem github: 'suzukaze/mruby-msgpack' # too much warn
  # conf.gem github:"Asmod4n/mruby-simplemsgpack" # trouble in travis
  # conf.gem github: 'hfm/mruby-fileutils' # error in mingw
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'

  if ENV['MRUBY_SIMPLEMSGPACK']
    conf.gem ENV['MRUBY_SIMPLEMSGPACK']
  else
    conf.gem github: "bismite/mruby-simplemsgpack", branch:'mruby3'
  end

  if ENV['MRUBY_BI_CORE']
    conf.gem ENV['MRUBY_BI_CORE']
  else
    conf.gem github: 'bismite/mruby-bi-core'
  end
  if ENV['MRUBY_BI_EXT']
    conf.gem ENV['MRUBY_BI_EXT']
  else
    conf.gem github: 'bismite/mruby-bi-ext'
  end
  if ENV['MRUBY_BI_SOUND']
    conf.gem ENV['MRUBY_BI_SOUND']
  else
    conf.gem github: 'bismite/mruby-bi-sound'
  end
  if ENV['MRUBY_BI_ARCHIVE']
    conf.gem ENV['MRUBY_BI_ARCHIVE']
  else
    conf.gem github: 'bismite/mruby-bi-archive'
  end
  if ENV['MRUBY_BI_GEOMETRY']
    conf.gem ENV['MRUBY_BI_GEOMETRY']
  else
    conf.gem github: 'bismite/mruby-bi-geometry'
  end
  if conf.name == "emscripten"
    if ENV['MRUBY_EMSCRIPTEN']
      conf.gem ENV['MRUBY_EMSCRIPTEN']
    else
      conf.gem github: 'bismite/mruby-emscripten'
    end
  end
  if ENV['MRUBY_BI_DLOPEN']
    conf.gem ENV['MRUBY_BI_DLOPEN']
  else
    conf.gem github: 'bismite/mruby-bi-dlopen'
  end
end
