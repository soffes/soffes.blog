require 'redis'

module Soffes
  module Blog
    def self.redis
      $redis ||= if url = ENV['REDIS_URL']
        Redis.new(url: url)
      else
        Redis.new
      end
    end
  end
end
