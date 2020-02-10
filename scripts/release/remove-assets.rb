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
  puts "release not found"
  exit
end

assets = release.assets
assets.each{|asset|
  puts "remove #{asset.name}"
  client.delete_release_asset asset.url
}
