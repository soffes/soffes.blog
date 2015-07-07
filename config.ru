require 'rubygems'
require 'bundler'
Bundler.require

use Rack::CanonicalHost, ENV['CANONICAL_HOST'] if ENV['CANONICAL_HOST']

$LOAD_PATH.unshift 'lib'
require 'soffes/blog/application'

require 'sprockets'
map '/assets' do
  sprockets = Sprockets::Environment.new
  sprockets.append_path 'assets/javascripts'
  sprockets.append_path 'assets/stylesheets'
  sprockets.append_path 'vendor/assets/javascripts'
  run sprockets
end

map '/' do
  run Soffes::Blog::Application
end
