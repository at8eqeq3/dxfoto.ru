source 'https://rubygems.org'
require 'json'
require 'open-uri'
gem 'aws-sdk', '~> 2'
gem 's3_website'
versions = JSON.parse(open('https://pages.github.com/versions.json').read)
gem 'github-pages', versions['github-pages']
