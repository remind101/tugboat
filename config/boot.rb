# dummy boot.rb file that is used in script/rails so we can use the
# `rails generate migration` command

require 'rubygems'
ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
require 'bundler'
Bundler.setup

$:.unshift File.expand_path('../../lib', __FILE__)
