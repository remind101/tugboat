Shipr.notifier = Shipr::Notifier::Null.new

RSpec.configure do |config|
  config.before do
    Shipr.notifier.reset
  end
end
