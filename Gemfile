source 'https://rubygems.org'

gem 'rake'
gem 'unicorn', '~> 4.6.2'

# Support
gem 'iron_worker_ng'
gem 'activesupport', '~> 3.2.13', require: 'active_support'

# API
gem 'grape',        '~> 0.4.1'
gem 'grape-entity', '~> 0.3.0'

# Persistence
gem 'redis'

group :development do
  gem 'rails', '~> 3.2.13'
  gem 'dotenv'
  gem 'shotgun'
  gem 'foreman'
end

group :test do
  gem 'rspec'
  gem 'database_cleaner'
  gem 'rack-test'
end
