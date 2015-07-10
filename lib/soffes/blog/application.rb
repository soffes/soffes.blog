require 'sinatra'
require 'json'
require 'soffes/blog/posts_controller'

module Soffes
  module Blog
    class Application < Sinatra::Application
      PAGE_SIZE = 3
      WEBHOOK_SECRET = ENV['WEBHOOK_SECRET'].freeze

      set :views, File.dirname(__FILE__) + '/../../../views'

      post '/_webhook' do
        content_type :json
        unless params[:secret] == WEBHOOK_SECRET
          return { error: 'Invalid secret.' }.to_json
        end

        require 'soffes/blog/importer'
        count = Soffes::Blog::Importer.new.import
        { imported: count }.to_json
      end

      get '/sitemap.xml' do
        @posts = []
        (1..PostsController.total_pages).each do |page|
          @posts += PostsController.posts(page)
        end
        content_type :xml
        erb :sitemap, layout: nil
      end

      get '/rss' do
        @posts = PostsController.posts(1)
        content_type :xml
        erb :rss, layout: nil
      end

      get '/rss/' do
        redirect '/rss'
      end

      get %r{^/$|/(\d+)$} do |page|
        @page = (page || 1).to_i
        @posts = PostsController.posts(@page)
        @total_pages = PostsController.total_pages

        erb :index
      end

      get %r{^/([\w\d\-]+)/$} do |key|
        redirect "/#{key}"
      end

      get %r{^/([\w\d\-]+)$} do |key|
        @post = PostsController.post(key)
        return erb :not_found unless @post

        @title = @post['title']
        @newer_post =  PostsController.newer_post(key)
        @older_post = PostsController.older_post(key)

        erb :show
      end
    end
  end
end
