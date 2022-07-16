source "http://rubygems.org"
require 'resolv-replace'
gem "fastlane"
gem "cocoapods"
gem "cocoapods-keys"
gem "cocoapods-check"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
