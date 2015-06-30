require 'sinatra'
require 'redis'
require 'json'

module Soffes
  module Blog
    class Application < Sinatra::Application
      PAGE_SIZE = 3

      get %r{/$|/(\d+)$} do |page|
        # Pagination
        page = (page || 1).to_i
        start_index = (page - 1) * PAGE_SIZE
        total_pages = (redis.zcard('sorted-slugs').to_f / PAGE_SIZE.to_f).ceil.to_i

        keys = redis.zrevrange('sorted-slugs', start_index, start_index + PAGE_SIZE - 1)
        slugs = []

        if keys.length > 0
          slugs = redis.hmget('slugs', *keys).map { |s| JSON.load(s) }
        end

        erb :index, locals: { slugs: slugs, page: page, total_pages: total_pages, window: 2 }
      end

      get %r{/([\w\d\-]+)$} do |key|
        slug = redis.hget('slugs', key)
        return erb :not_found unless slug && slug.length > 0

        erb :slug, locals: { slug: JSON.load(slug) }
      end

      private

      def redis
        Soffes::Blog.redis
      end
    end
  end
end
