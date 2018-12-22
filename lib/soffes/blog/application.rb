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

      get '/rss/?' do
        redirect '/feeds/rss'
      end

      get '/feeds/rss/?' do
        @page = (params[:page] || 1).to_i
        @total_pages = PostsController.total_pages
        @posts = PostsController.posts(@page)
        content_type :xml
        erb :rss, layout: nil
      end

      get '/feeds/json/?' do
        content_type 'application/json; charset=utf8'

        feed = {
          version: 'https://jsonfeed.org/version/1',
          title: 'Hi, I’m Sam',
          description: 'This is my blog. Enjoy.',
          home_page_url: 'https://soffes.blog/',
          feed_url: 'https://soffes.blog/feeds/json',
          icon: 'https://soffes.blog/icon.png',
          favicon: 'https://soffes.blog/favicon.png',
          author: {
            name: 'Sam Soffes',
            url: 'https://soff.es/',
            avatar: 'https://soffes-assets.s3.amazonaws.com/images/Sam-Soffes.jpg'
          }
        }

        page = (params[:page] || 1).to_i
        total_pages = PostsController.total_pages

        if page < total_pages
          feed[:next_url] = feed[:feed_url] + "?page=#{page + 1}"
        end

        posts = PostsController.posts(page)
        feed[:items] = posts.map do |post|
          url = "https://soffes.blog/#{post['key']}"
          item = {
            id: url,
            url: url,
            title: post['title'],
            content_html: post['html'],
            date_published: Time.at(post['published_at']).to_datetime.rfc3339
          }

          if tags = post['tags']
            item[:tags] = tags
          end

          item['banner_image'] = post['cover_image'] if post['cover_image']

          item
        end

        feed.to_json
      end

      get %r{/page/(\d+)} do |page|
        redirect "/#{page}"
      end

      get %r{/(\d+)} do |page|
        redirect "/?page=#{page}"
      end

      get '/' do
        @page = (params[:page] || 1).to_i
        @posts = PostsController.posts(@page)
        @total_pages = PostsController.total_pages

        erb :index
      end

      get %r{/([\w\-]+)/} do |key|
        redirect "/#{key}"
      end

      get %r{/([\w\-]+)} do |key|
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
