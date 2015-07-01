require 'date'
require 'redcarpet'
require 'json'
require 'nokogiri'
require 'aws-sdk'

module Soffes
  module Blog
    class Importer
      BLOG_GIT_URL = 'https://github.com/soffes/blog.git'.freeze
      MARKDOWN_OPTIONS = options = {
        no_intra_emphasis: true,
        tables: true,
        fenced_code_blocks: true,
        autolink: true,
        strikethrough: true,
        space_after_headers: true,
        superscript: true
      }.freeze
      AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID'] || raise('You need to define the AWS_ACCESS_KEY_ID env var')
      AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'] || raise('You need to define the AWS_SECRET_ACCESS_KEY env var')
      AWS_S3_REGION = ENV['AWS_S3_REGION'] || 'us-east-1'
      AWS_S3_BUCKET_NAME = ENV['AWS_S3_BUCKET_NAME'] || raise('You need to define the AWS_S3_BUCKET_NAME env var')

      def import
        unless File.exists?('tmp/repo')
          puts 'Cloning posts...'
          `git clone --depth 1 #{BLOG_GIT_URL} tmp/repo`
        else
          puts 'Updating posts...'
          'cd tmp/repo && git pull origin master'
        end

        markdown = Redcarpet::Markdown.new(Soffes::Blog::MarkdownRenderer, MARKDOWN_OPTIONS)

        # Posts
        Dir['tmp/repo/published/*'].each do |path|
          matches = path.match(/\/(\d{4})-(\d{2})-(\d{2})-([\w\-]+)$/)
          key = matches[4]

          puts "Importing #{key}"

          # Load content
          contents = File.open("#{path}/#{key}.markdown").read

          # Meta data
          meta = {
            key: key,
            title: key.capitalize,
            published_at: Date.new(matches[1].to_i, matches[2].to_i, matches[3].to_i).to_time.utc.to_i,
            type: 'post'
          }

          # Extract YAML front matter
          if result = contents.match(/\A(---\s*\n.*?\n?)^(---\s*$\n?)/m)
            contents = contents[(result[0].length)...(contents.length)]
            meta.merge!(YAML.safe_load(result[0]))
          end

          # Upload cover image
          if cover_image = meta['cover_image']
            puts "  Uploading cover image..."
            upload("#{path}/#{cover_image}", "#{key}/#{cover_image}")
          end

          # Parse Markdown
          html = markdown.render(contents)

          # Remove H1
          doc = Nokogiri::HTML.fragment(html)
          h1 = doc.search('.//h1').remove
          meta[:title] = h1.text if h1.text.length > 0
          meta[:html] = doc.to_html

          # Upload images
          doc.css('img').each do |i|
            src = i['src']
            next if src.start_with?('http')

            image_path = "#{path}/#{src}"
            next unless File.exists?(image_path)

            puts "  Uploading #{src}"
            upload(image_path, "#{key}/#{src}")
          end

          # Store in Redis
          redis.hset('slugs', key, JSON.dump(meta))
          redis.zadd('sorted-slugs', meta[:published_at], key)
        end

        puts 'Done!'
      end

      private

      def redis
        Soffes::Blog.redis
      end

      def aws
        @aws ||= Aws::S3::Client.new(
          region: AWS_S3_REGION,
          access_key_id: AWS_ACCESS_KEY_ID,
          secret_access_key: AWS_SECRET_ACCESS_KEY
        )
      end

      def upload(local, key)
        bucket = Aws::S3::Resource.new(client: aws).bucket(AWS_S3_BUCKET_NAME)
        bucket.object(key).upload_file(local, acl: 'public-read')
      end
    end
  end
end
