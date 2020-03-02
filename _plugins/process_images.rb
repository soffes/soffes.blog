require 'nokogiri'
require 'mini_magick'

module MiniMagick
  class Image
    def pixel_at(x, y)
      run_command("convert", "#{path}[1x1+#{x.to_i}+#{y.to_i}]", 'txt:').split("\n").each do |line|
        return $1 if /^0,0:.*(#[0-9a-fA-F]+)/.match(line)
      end
      nil
    end
  end
end

class ImageProcessor
  IMAGE_SIZES = [1024, 508, 382, 343, 336, 288, 187, 168, 140, 122, 109, 90].freeze

  def initialize(post)
    @post = post
    @site = post.site
  end

  def process!
    doc = Nokogiri::HTML.fragment(@post.output)
    doc.css('img').each do |node|
      next unless src = node['src']
      next if src.start_with?('http')
      next unless src.end_with?('png') || src.end_with?('jpg')

      process_image(node)
    end

    @post.output = doc.to_html
  end

  private

  def process_image(node)
    src = node['src']
    url = @site.config['cdn_url'] + src
    srcset = []

    IMAGE_SIZES.each do |size|
      srcset += ["#{url}?w=#{size} 1x", "#{url}?w=#{size}&dpr=2 2x", "#{url}?w=#{size}&dpr=3 3x"]
    end

    node['src'] = "#{url}?w=#{IMAGE_SIZES.last}"
    node['srcset'] = srcset.join(',')

    node['loading'] = 'lazy'

    if src.end_with?('jpg')
      image = MiniMagick::Image.open(".#{src}")

      size = image.dimensions
      node['data-width'] = size[0]
      node['data-height'] = size[1]

      if ENV['RACK_ENV'] == 'production'
        image.resize('1x1')
        if color = image.pixel_at(1, 1)
          node['style'] = "background-color:#{color.downcase}"
        end
      end
    end
  end
end

Jekyll::Hooks.register :posts, :post_render do |post|
  ImageProcessor.new(post).process!
end
