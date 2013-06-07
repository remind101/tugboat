source 'https://rubygems.org'

gem 'rake'
gem 'unicorn', '~> 4.6.2'

# Support
gem 'rack-contrib'
gem 'json',           '~> 1.8.0'
gem 'virtus',         '~> 0.5.4'
gem 'activesupport',  '~> 3.2.13', require: 'active_support'
gem 'activemodel',    '~> 3.2.13', require: 'active_model'
gem 'eventmachine',   '~> 1.0.0.beta'

# Workers
gem 'iron_worker_ng', '~> 0.16.4'

# Messages
gem 'iron_mq', '~> 4.0.3'
gem 'sinatra'

# Frontend
gem 'sinatra_auth_github'
gem 'haml'

# API
gem 'grape',        '~> 0.4.1'
gem 'grape-entity', '~> 0.3.0'
gem 'rack-ssl'

# Persistence
gem 'redis'
gem 'activerecord', '~> 3.2.13', require: 'active_record'
gem 'pg',           '~> 0.15.1'

# Authentication
gem 'warden'

group :development do
  gem 'rails', '~> 3.2.13', require: false
  gem 'micro_migrations', git: 'https://gist.github.com/2087829.git'
  gem 'dotenv'
  gem 'shotgun'
  gem 'foreman'
  gem 'guard-rspec'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'webmock'
end
