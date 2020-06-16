require 'rbconfig'

BUILD_DIR = File.expand_path File.join __dir__, "..", "build"
if /darwin|mac os/ === RbConfig::CONFIG['host_os']
  FRAMEWORKS_DIR = "#{ENV['HOME']}/Library/Frameworks"
  HOST="macos"
else
  FRAMEWORKS_DIR = nil
  HOST="linux"
end

MINGW_AVAILABLE = ENV['MINGW_AVAILABLE']
EMSCRIPTEN_AVAILABLE = ENV['EMSCRIPTEN_AVAILABLE']

OPTIMIZE = "-O3"
C_STD="-std=gnu11"
CXX_STD="-std=gnu++11"
COMMON_CFLAGS = %W( -DNDEBUG -Wall -Werror-implicit-function-declaration -Wwrite-strings)
COMMON_DEFINES = %w(MRB_INT64 MRB_UTF8_STRING)

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
  conf.gem github: "bismite/mruby-simplemsgpack"
  # conf.gem github: 'hfm/mruby-fileutils' # error in mingw
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'

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
  if ENV['MRUBY_DLOPEN']
    conf.gem ENV['MRUBY_DLOPEN']
  else
    conf.gem github: 'bismite/mruby-dlopen'
  end
end

MRuby::Build.new do |conf|
  toolchain :clang

  conf.enable_bintest = false
  conf.enable_test = false

  include_gems conf

  conf.cc do |cc|
    cc.command = 'clang'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include"
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include/SDL2"
  end
  conf.cc.flags = COMMON_CFLAGS + [ OPTIMIZE, C_STD ]
  if HOST == "linux"
    conf.cc.flags << "`sdl2-config --cflags`"
  end

  conf.cxx do |cxx|
    cxx.command = 'clang++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/#{HOST}/include"
    cc.include_paths << "#{BUILD_DIR}/#{HOST}/include/SDL2"
  end
  conf.cxx.flags = COMMON_CFLAGS + [ OPTIMIZE, CXX_STD ]
  if HOST == "linux"
    conf.cxx.flags << "`sdl2-config --cflags`"
  end

  conf.linker do |linker|
    linker.command = 'clang'
    linker.library_paths << "#{BUILD_DIR}/#{HOST}/lib"
    # linker.libraries << "stdc++"
    linker.libraries += %W( bi biext GLEW SDL2 SDL2_image SDL2_mixer )
    if HOST == "macos"
      linker.libraries << "mpg123"
      linker.flags << "-framework OpenGL"
    else
      linker.libraries << "GL"
      linker.libraries << "dl"
    end
  end
end


MRuby::CrossBuild.new('mingw') do |conf|
  toolchain :gcc
  conf.host_target = "x86_64-w64-mingw32"

  conf.enable_bintest = false
  conf.enable_test = false

  include_gems(conf)

  conf.cc do |cc|
    cc.command = 'x86_64-w64-mingw32-gcc'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/#{conf.host_target}/include"
  end
  conf.cc.flags = COMMON_CFLAGS + [OPTIMIZE, C_STD]
  conf.cc.flags << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --cflags`"

  conf.cxx do |cxx|
    cxx.command = 'x86_64-w64-mingw32-g++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/#{conf.host_target}/include"
  end
  conf.cxx.flags = COMMON_CFLAGS + [OPTIMIZE, CXX_STD]
  conf.cxx.flags << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --cflags`"

  conf.linker do |linker|
    linker.command = 'x86_64-w64-mingw32-g++'
    linker.library_paths << "#{BUILD_DIR}/#{conf.host_target}/lib"
    linker.libraries += %w(biext bi glew32 opengl32 libdl)
    linker.flags_after_libraries << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --libs` -lSDL2_image -lSDL2_mixer -static-libgcc -mconsole"
  end

  conf.exts do |exts|
    exts.executable = '.exe'
  end

  conf.archiver.command = 'x86_64-w64-mingw32-ar'
end if MINGW_AVAILABLE


MRuby::CrossBuild.new('emscripten') do |conf|
  toolchain :clang

  conf.enable_bintest = false
  conf.enable_test = false

  include_gems(conf)

  emscripten_flags = %W(-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' -s DISABLE_EXCEPTION_CATCHING=0 -s MAIN_MODULE=1 -fPIC -s WASM=1)
  emscripten_optimize_level = "-Oz"

  conf.cc do |cc|
    cc.command = 'emcc'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/emscripten/include"
    cc.flags = COMMON_CFLAGS + [ emscripten_optimize_level, C_STD ]
    cc.flags += emscripten_flags
  end

  conf.cxx do |cxx|
    cxx.command = 'em++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/emscripten/include"
    cxx.flags = COMMON_CFLAGS + [emscripten_optimize_level, CXX_STD]
    cxx.flags += emscripten_flags
  end

  conf.linker do |linker|
    linker.command = 'emcc'
    linker.library_paths << "#{BUILD_DIR}/emscripten/lib"
    linker.libraries += %w(biext bi)
    linker.flags += emscripten_flags
  end

  conf.archiver.command = 'emar'
end if EMSCRIPTEN_AVAILABLE
