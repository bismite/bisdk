#!/usr/bin/env ruby
require_relative "../lib/utils"

SDL2_VERSION = "SDL2-2.0.14"
SDL2_TGZ = "#{SDL2_VERSION}.tar.gz"

TMP_BUILD_DIR = "/tmp/"
DOWNLOAD_DIR = "build/download/macos"
TGZ_PATH = File.absolute_path( File.join(DOWNLOAD_DIR,SDL2_TGZ) )
PREFIX = install_path "macos"

mkdir_p TMP_BUILD_DIR

FileUtils.cd(TMP_BUILD_DIR,verbose:true) do
  run "tar zxf #{TGZ_PATH}"
  FileUtils.cd(SDL2_VERSION,verbose:true) do
    run "./configure --prefix=#{PREFIX}"
    run "make install"
  end
end
