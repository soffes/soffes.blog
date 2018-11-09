source 'https://rubygems.org'

# Latest Ruby
ruby '2.5.1'

# Web server
gem 'puma'

# Simple HTTP
gem 'sinatra'

# Use the right host
gem 'rack-canonical-host'

# ACME challenges
gem 'acme_challenge'

# Always use SSL
gem 'rack-ssl'

# Faster ERB
gem 'erubis'

# Markdown
gem 'redcarpet', require: false

# Code coloring
gem 'pygments.rb', require: false

# HTML manipulation
gem 'nokogiri', require: false

# Redis client
gem 'redis'

# Safety
gem 'safe_yaml'

# Asset pipeline
gem 'sprockets'
gem 'sass'
gem 'sprockets-sass'
gem 'uglifier'

# Utilities
gem 'rake', require: false

# JSON
gem 'json'

# Image dimensions
gem 'dimensions', require: false

# Asset uploading
gem 'aws-sdk-s3', require: false

group :development do
  # Automatic reloading
  gem 'shotgun', require: false
end

group :test do
  # Code coverage
  gem 'simplecov', require: false
  gem 'coveralls', require: false

  # Fake Redis
  gem 'fakeredis'

  # Web testing
  gem 'capybara'

  # Testing
  gem 'minitest', '>= 5.0'

  # Colored output
  gem 'minitest-reporters', require: 'minitest/reporters'
end
