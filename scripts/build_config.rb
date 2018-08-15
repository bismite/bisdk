require 'rbconfig'

BUILD_DIR = File.expand_path File.join __dir__, "..", "build"
if /darwin|mac os/ === RbConfig::CONFIG['host_os']
  FRAMEWORKS_DIR = "#{ENV['HOME']}/Library/Frameworks"
else
  FRAMEWORKS_DIR = nil
end

MINGW_AVAILABLE = ENV['MINGW_AVAILABLE']
EMSCRIPTEN_AVAILABLE = ENV['EMSCRIPTEN_AVAILABLE']

MRuby::Build.new do |conf|
  toolchain :gcc

  conf.gembox 'default'
  conf.gem mgem: 'mruby-singleton'
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'
  conf.gem github: 'bismite/mruby-bi-core'
  conf.gem github: 'bismite/mruby-bi-ext'
  # conf.gem "#{ENV['HOME']}/git/bismite/mruby-bi-core"
  # conf.gem "#{ENV['HOME']}/git/bismite/mruby-bi-ext"

  conf.cc do |cc|
    cc.command = '/usr/bin/gcc'
    # XXX: use gnu11
    cc.flags = %W(-g -std=gnu11 -O3 -Wall -Werror-implicit-function-declaration -Wdeclaration-after-statement -Wwrite-strings)
    if FRAMEWORKS_DIR
      cc.flags += %W(-F #{FRAMEWORKS_DIR})
    else
      cc.flags << "`sdl2-config --cflags`"
    end
    # cc.defines += %w(MRB_32BIT MRB_UTF8_STRING GC_DEBUG)
    cc.defines += %w(MRB_32BIT MRB_UTF8_STRING)
    cc.include_paths << "#{BUILD_DIR}/host/include"
  end

  conf.linker do |linker|
    linker.command = '/usr/bin/gcc'
    linker.library_paths << "#{BUILD_DIR}/host/lib"
    linker.libraries += %w(biext bi GLEW)

    if FRAMEWORKS_DIR
      linker.flags << "-F #{FRAMEWORKS_DIR}"
      linker.flags << "-framework SDL2 -framework SDL2_image -framework OpenGL"
    else
      linker.libraries << "GL"
      linker.flags_after_libraries << "`sdl2-config --libs` -lSDL2_image"
    end
  end

  conf.enable_bintest = false
  conf.enable_test = false
end

MRuby::CrossBuild.new('mingw') do |conf|
  toolchain :gcc
  conf.host_target = "x86_64-w64-mingw32"

  conf.gembox 'default'
  conf.gem :mgem => 'mruby-singleton'
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'
  conf.gem github: 'bismite/mruby-bi-core'
  conf.gem github: 'bismite/mruby-bi-ext'
  # conf.gem "#{ENV['HOME']}/git/bismite/mruby-bi-core"
  # conf.gem "#{ENV['HOME']}/git/bismite/mruby-bi-ext"

  conf.cc do |cc|
    cc.command = 'x86_64-w64-mingw32-gcc'
    # XXX: use gnu11
    cc.flags = %W(-g -std=gnu11 -O3 -Wall -Werror-implicit-function-declaration -Wdeclaration-after-statement -Wwrite-strings)
    cc.flags << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --cflags`"
    cc.defines += %w(MRB_32BIT MRB_UTF8_STRING)
    cc.include_paths << "#{BUILD_DIR}/#{conf.host_target}/include"
  end

  conf.linker do |linker|
    linker.command = 'x86_64-w64-mingw32-gcc'
    linker.library_paths << "#{BUILD_DIR}/#{conf.host_target}/lib"
    linker.libraries += %w(biext bi glew32 opengl32)
    linker.flags_after_libraries << "`#{BUILD_DIR}/#{conf.host_target}/bin/sdl2-config --libs` -lSDL2_image"
  end

  conf.archiver.command = 'x86_64-w64-mingw32-ar'
end if MINGW_AVAILABLE



MRuby::CrossBuild.new('emscripten') do |conf|
  toolchain :clang

  conf.gembox 'default'
  conf.gem :mgem => 'mruby-singleton'
  conf.gem github: 'kabies/mruby-stable-sort'
  conf.gem github: 'kabies/mruby-cellular-automaton'
  conf.gem github: 'bismite/mruby-bi-core'
  conf.gem github: 'bismite/mruby-bi-ext'
  # conf.gem "#{ENV['HOME']}/git/bismite/mruby-bi-core"
  # conf.gem "#{ENV['HOME']}/git/bismite/mruby-bi-ext"

  conf.cc do |cc|
    cc.command = 'emcc'
    cc.defines += %w(MRB_32BIT MRB_UTF8_STRING)
    cc.include_paths << "#{BUILD_DIR}/emscripten/include"

    # XXX: use gnu11, Oz
    cc.flags = %W(-g -std=gnu11 -Oz -Wall -Werror-implicit-function-declaration -Wdeclaration-after-statement -Wwrite-strings)
    cc.flags += %W(-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' )
  end

  conf.linker do |linker|
    linker.command = 'emcc'
    linker.library_paths << "#{BUILD_DIR}/emscripten/lib"
    linker.libraries << 'bi'
    linker.libraries << 'biext'
  end

  conf.archiver.command = 'emar'
end if EMSCRIPTEN_AVAILABLE
