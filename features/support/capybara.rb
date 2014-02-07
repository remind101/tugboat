require 'capybara'

World(Capybara::DSL)

Capybara.app = Shipr.app
Capybara.default_driver = :selenium

World(Rack::Test::Methods)

def app
  Capybara.app
end
