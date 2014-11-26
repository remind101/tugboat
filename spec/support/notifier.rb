Shipr.configuration.notifier = Shipr::Notifier::Null.new

RSpec.configure do |config|
  config.before do
    Shipr.configuration.notifier.reset
  end
end
