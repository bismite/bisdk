require 'rbconfig'

BUILD_DIR = File.expand_path File.join __dir__, "..", "build"
if /darwin|mac os/ === RbConfig::CONFIG['host_os']
  FRAMEWORKS_DIR = "#{ENV['HOME']}/Library/Frameworks"
else
  FRAMEWORKS_DIR = nil
end

MINGW_AVAILABLE = ENV['MINGW_AVAILABLE']
EMSCRIPTEN_AVAILABLE = ENV['EMSCRIPTEN_AVAILABLE']

OPTIMIZE = "-O3"
C_STD="-std=gnu11"
CXX_STD="-std=gnu++11"
COMMON_CFLAGS = %W(-g -Wall -Werror-implicit-function-declaration -Wdeclaration-after-statement -Wwrite-strings)
COMMON_DEFINES = %w(MRB_32BIT MRB_UTF8_STRING)

MRuby::Build.new do |conf|
  toolchain :gcc

  conf.enable_cxx_exception
  conf.enable_bintest = false
  conf.enable_test = false

  conf.gembox 'default'
  conf.gem mgem: 'mruby-singleton'
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'
  conf.gem github: 'bismite/mruby-bi-core'
  conf.gem github: 'bismite/mruby-bi-ext'
  conf.gem github: 'bismite/mruby-bi-sound'

  conf.cc do |cc|
    cc.command = '/usr/bin/gcc'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/host/include"
  end
  conf.cc.flags = COMMON_CFLAGS + [ OPTIMIZE, C_STD ]
  if FRAMEWORKS_DIR
    conf.cc.flags += %W(-F #{FRAMEWORKS_DIR})
  else
    conf.cc.flags << "`sdl2-config --cflags`"
  end

  conf.cxx do |cxx|
    cxx.command = '/usr/bin/g++'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/host/include"
  end
  conf.cxx.flags = COMMON_CFLAGS + [ OPTIMIZE, CXX_STD ]
  if FRAMEWORKS_DIR
    conf.cxx.flags += %W(-F #{FRAMEWORKS_DIR})
  else
    conf.cxx.flags << "`sdl2-config --cflags`"
  end

  conf.linker do |linker|
    linker.command = '/usr/bin/gcc'
    linker.library_paths << "#{BUILD_DIR}/host/lib"
    linker.libraries += %W(biext bi GLEW stdc++)
    if FRAMEWORKS_DIR
      linker.flags << "-F #{FRAMEWORKS_DIR}"
      linker.flags << "-framework SDL2 -framework SDL2_image -framework SDL2_mixer -framework OpenGL"
    else
      linker.libraries << "GL"
      linker.flags_after_libraries << "`sdl2-config --libs` -lSDL2_image -lSDL2_mixer"
    end
  end
end


MRuby::CrossBuild.new('mingw') do |conf|
  toolchain :gcc
  conf.host_target = "x86_64-w64-mingw32"

  conf.enable_cxx_exception
  conf.enable_bintest = false
  conf.enable_test = false

  conf.gembox 'default'
  conf.gem :mgem => 'mruby-singleton'
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'
  conf.gem github: 'bismite/mruby-bi-core'
  conf.gem github: 'bismite/mruby-bi-ext'
  conf.gem github: 'bismite/mruby-bi-sound'

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
    linker.command = 'x86_64-w64-mingw32-gcc'
    linker.library_paths << "#{BUILD_DIR}/#{conf.host_target}/lib"
    linker.libraries += %w(biext bi glew32 opengl32 stdc++)
    linker.flags_after_libraries << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --libs` -lSDL2_image -lSDL2_mixer"
  end

  conf.archiver.command = 'x86_64-w64-mingw32-ar'
end if MINGW_AVAILABLE


MRuby::CrossBuild.new('emscripten') do |conf|
  toolchain :clang

  conf.enable_cxx_exception
  conf.enable_bintest = false
  conf.enable_test = false

  conf.gembox 'default'
  conf.gem :mgem => 'mruby-singleton'
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'
  conf.gem github: 'bismite/mruby-bi-core'
  conf.gem github: 'bismite/mruby-bi-ext'
  conf.gem github: 'bismite/mruby-bi-sound'

  conf.cc do |cc|
    cc.command = 'emcc'
    cc.defines += COMMON_DEFINES
    cc.include_paths << "#{BUILD_DIR}/emscripten/include"
  end
  conf.cc.flags = COMMON_CFLAGS + [ "-Oz", C_STD ]
  conf.cc.flags += %W(-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' )

  conf.cxx do |cxx|
    cxx.command = 'emcc'
    cxx.defines += COMMON_DEFINES
    cxx.include_paths << "#{BUILD_DIR}/emscripten/include"
  end
  conf.cxx.flags = COMMON_CFLAGS + ["-Oz", CXX_STD]
  conf.cxx.flags += %W(-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' )

  conf.linker do |linker|
    linker.command = 'emcc'
    linker.library_paths << "#{BUILD_DIR}/emscripten/lib"
    linker.libraries += %w(biext bi)
    linker.flags += %W(-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' )
  end

  conf.archiver.command = 'emar'
end if EMSCRIPTEN_AVAILABLE
