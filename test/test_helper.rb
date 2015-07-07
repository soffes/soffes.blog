require 'bundler'
Bundler.require :test

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end

  require 'coveralls'
  Coveralls.wear!
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'soffes/blog'
require 'soffes/blog/importer'

# require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new({ color: true })]
require 'minitest/autorun'

Capybara.app = Soffes::Blog::Application

module Soffes::Blog
  class Test < Minitest::Test
    def setup
      super
      Redis.new.flushdb
    end

    protected

    def factory(key:, title: key, html: '<p>Hi</p>', published_at: Time.now.to_i)
      {
        'key' => key,
        'title' => title,
        'html' => html,
        'published_at' => published_at
      }
    end
  end

  class IntegrationTest < Test
    include Capybara::DSL

    def teardown
      Capybara.reset_sessions!
      Capybara.use_default_driver
      super
    end
  end
end
