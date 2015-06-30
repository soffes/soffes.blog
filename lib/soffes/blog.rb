module Soffes
  module Blog
    def self.redis
      $redis ||= if ENV['REDIS_URL'] && ENV['REDIS_URL'].length > 0
        require 'uri'
        uri = URI.parse(ENV['REDIS_URL'])
        Redis.new(host: uri.host, port: uri.port, password: uri.password)
      else
        Redis.new
      end
    end
  end
end

require 'soffes/blog/application'
require 'soffes/blog/markdown_renderer'
