ENV['RACK_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.before do
    IronWorkerNG::Client.stub new: double(IronWorkerNG::Client).as_null_object
    IronMQ::Client.stub new: double(IronMQ::Client).as_null_object
  end
end
