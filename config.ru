require File.expand_path('../config/environment', __FILE__)

Deployer.connect!

run Deployer.app
