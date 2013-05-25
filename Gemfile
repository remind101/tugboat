source 'https://rubygems.org'

gem 'rake'
gem 'unicorn', '~> 4.6.2'

# Support
gem 'iron_worker_ng'
gem 'activesupport', '~> 3.2.13', require: 'active_support'

# API
gem 'grape',        '~> 0.4.1'
gem 'grape-entity', '~> 0.3.0'

# Database
gem 'pg',           '~> 0.15.1'
gem 'activerecord', '~> 3.2.13', require: 'active_record'

group :development do
  gem 'rails', '~> 3.2.13'
  gem 'micro_migrations', git: 'https://gist.github.com/2087829.git'
  gem 'dotenv'
  gem 'shotgun'
  gem 'foreman'
end

group :test do
  gem 'rspec'
  gem 'database_cleaner'
  gem 'rack-test'
end
