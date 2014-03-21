require 'securerandom'

ENV['RACK_ENV']      = 'test'
ENV['COOKIE_SECRET'] = SecureRandom.hex

require File.expand_path('../../../config/environment.rb', __FILE__)

Bundler.require :features
