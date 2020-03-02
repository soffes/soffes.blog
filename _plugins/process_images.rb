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
  # 4.5", 4.0" (2x):            228w, 140w,  91w,  66w
  # 4.7", 5.8" (2x, 3x):        343w, 168w, 109w,  80w
  # 5.5", 6.1", 6.5" (2x, 3x):  382w, 137w, 122w,  90w
  # Deskop (1x, 2x, 3x):       1024w, 508w, 336w, 250w
  IMAGE_SIZES = [
    [
      { width: 1024, scales: [1, 2, 3] },
      { width: 382, scales: [2, 3] },
      { width: 343, scales: [2, 3] },
      { width: 228, scales: [2] }
    ],
    [
      { width: 508, scales: [1, 2, 3] },
      { width: 137, scales: [2, 3] },
      { width: 168, scales: [2, 3] },
      { width: 140, scales: [2] }
    ],
    [
      { width: 336, scales: [1, 2, 3] },
      { width: 122, scales: [2, 3] },
      { width: 109, scales: [2, 3] },
      { width: 91, scales: [2] }
    ],
    [
      { width: 250, scales: [1, 2, 3] },
      { width: 90, scales: [2, 3] },
      { width: 80, scales: [2, 3] },
      { width: 66, scales: [2] }
    ]
  ].freeze

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

    sizes = node.parent.name == 'photo-row' ? IMAGE_SIZES[node.parent.css('img').count - 1] : IMAGE_SIZES.first
    sizes.each do |size|
      size[:scales].reverse.each do |scale|
        srcset += ["#{url}?w=#{size[:width]}&dpr=#{scale} #{scale}x"]
      end
    end

    node['src'] = "#{url}?w=1024"
    node['srcset'] = srcset.join(',')

    node['loading'] = 'lazy' unless node['loading']

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
