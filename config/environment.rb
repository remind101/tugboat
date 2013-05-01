ENV['RACK_ENV'] ||= 'development'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'deployer'

if Deployer.env.development?
  require 'dotenv'
  Dotenv.load
end
