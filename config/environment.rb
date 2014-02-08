ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV']

begin
  require 'dotenv'
  Dotenv.load
rescue LoadError
  # We don't use dotenv on production
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'shipr'

require_relative './mongoid.rb'
