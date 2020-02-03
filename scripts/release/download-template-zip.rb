#!/usr/bin/env ruby

require "dotenv"
require "octokit"

Dotenv.load

TARGET_TAG = "0.1.0"
ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN']

client = Octokit::Client.new( access_token: ACCESS_TOKEN )

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
  template-macos.zip
  template-linux.zip
  template-x86_64-w64-mingw32.zip
  template-emscripten.zip
).each{|zip|
  asset = assets.find{|a| a.name == File.basename(zip) }
  if asset
    asset_url = "https://#{ACCESS_TOKEN}@api.github.com/repos/bismite/bisdk/releases/assets/#{asset.id}"
    puts "download #{zip} from #{asset_url}"
    `curl -# -L -o build/bisdk/#{zip} -H 'Accept: application/octet-stream' #{asset_url}`
  else
    puts "not found #{zip}"
  end
}
