require 'soffes/blog/redis'
require 'json'

module Soffes
  module Blog
    class PostsController
      SORTED_SET_KEY = 'sorted-posts'.freeze
      HASH_KEY = 'posts'.freeze
      DEFAULT_PAGE_SIZE = 5.freeze

      # Save a post given its JSON
      def self.insert_post(post)
        redis.hset(HASH_KEY, post['key'], JSON.dump(post))
        redis.zadd(SORTED_SET_KEY, post['published_at'], post['key'])
        post
      end

      # Get a post's JSON given a key
      def self.post(key)
        return nil unless key && json = redis.hget(HASH_KEY, key)
        JSON.load(json)
      end

      # Get the next newest post given a post key
      def self.newer_post(key)
        index = redis.zrank(SORTED_SET_KEY, key)
        newer_key = redis.zrange(SORTED_SET_KEY, index + 1, index + 2).first
        post(newer_key)
      end

      # Get the next oldest post given a post key
      def self.older_post(key)
        index = redis.zrank(SORTED_SET_KEY, key)
        newer_key = redis.zrange(SORTED_SET_KEY, index - 1, index).first
        post(newer_key)
      end

      # Get a list of posts given an optional page
      def self.posts(page = 1, page_size = DEFAULT_PAGE_SIZE)
        start_index = (page - 1) * page_size
        keys = redis.zrevrange(SORTED_SET_KEY, start_index, start_index + page_size - 1)
        return [] unless keys.length > 0

        redis.hmget(HASH_KEY, *keys).map { |post| JSON.load(post) }
      end

      # Get the total number of pages
      def self.total_pages(page_size = DEFAULT_PAGE_SIZE)
        (redis.zcard(SORTED_SET_KEY).to_f / page_size.to_f).ceil.to_i
      end

      private

      def self.redis
        Soffes::Blog.redis
      end
    end
  end
end
