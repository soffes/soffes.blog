require 'redis'

module Soffes
  module Blog
    def self.redis
      $redis ||= ENV['REDIS_URL'] ? Redis.new(url: ENV['REDIS_URL']) : Redis.new
    end
  end
end
