#!/usr/bin/env ruby

require "dotenv"
require "octokit"

Dotenv.load

TARGET_TAG = "0.1.0"

access_token = ENV['GITHUB_ACCESS_TOKEN']
client = Octokit::Client.new( access_token: access_token )

releases = client.releases "bismite/bisdk"
releases = releases.select{|r| r.tag_name == TARGET_TAG}.sort_by(&:created_at)

release = releases.first

if release
  puts "#{release.html_url} found."
else
  puts "create release"
  release = client.create_release("bismite/bisdk", TARGET_TAG, draft:true );
end

assets = release.assets

%w(
  build/macos/template-macos.zip
  build/macos/template-linux.zip
  build/x86_64-w64-mingw32/template-x86_64-w64-mingw32.zip
  build/emscripten/template-emscripten.zip
).each{|zip|
  next unless File.exist? zip
  if assets.find{|a| a.name == File.basename(zip) }
    puts "already uploaded #{zip}"
  else
    puts "upload #{zip}"
    client.upload_asset(release.url, zip )
  end
}
