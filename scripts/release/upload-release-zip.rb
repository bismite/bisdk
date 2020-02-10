#!/usr/bin/env ruby

require "dotenv"
require "octokit"

Dotenv.load

TARGET_TAG = `git tag --points-at HEAD`.strip
if TARGET_TAG.empty?
  puts "no tag"
  exit
else
  puts "search #{TARGET_TAG}"
end

access_token = ENV['GITHUB_ACCESS_TOKEN']
client = Octokit::Client.new( access_token: access_token )

releases = client.releases "bismite/bisdk"
release = releases.select{|r| r.tag_name == TARGET_TAG}.sort_by(&:created_at).first


if release
  puts "#{release.html_url} found."
else
  puts "create release"
  release = client.create_release("bismite/bisdk", TARGET_TAG, draft:true );
end

assets = release.assets

def zip_release(dir,filename)
  if File.exist? "#{dir}/bisdk"
    cmd = "(cd #{dir}; zip --quiet --symlinks -r ../#{filename} bisdk -x '*/\__MACOSX' -x '*/\.*')"
    puts cmd
    system cmd
  else
    puts "#{dir}/bisdk not exist"
  end
end

%w(
  macos macos
  linux linux
  x86_64-w64-mingw32 windows
).each_slice(2){|target,name|

  dir = "build/#{target}"
  filename = "bisdk-#{name}-#{TARGET_TAG}.zip"
  zip = "build/#{filename}"

  if File.exist?(zip)
    if `find #{dir} -newer #{zip}`.empty?
      puts "#{zip} already exist."
    else
      puts "remove #{zip}"
      File.delete(zip)
      zip_release dir, filename
    end
  else
    zip_release dir, filename
  end

  if assets.find{|a| a.name == filename }
    puts "already uploaded #{filename}"
  else
    if File.exist? zip
      puts "upload #{zip}"
      client.upload_asset release.url, zip
    else
      puts "#{zip} not found"
    end
  end
}
