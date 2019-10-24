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
  IMAGE_SIZES = [640, 1024]

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

      path = ".#{src}"
      unless File.exist?(path)
        puts "--------> Missing image #{path}"
        next
      end

      process_image(node)
    end

    @post.output = doc.to_html
  end

  private

  def process_image(node)
    path = node['src']
    full_path = ".#{path}"
    srcset = []
    original_width = MiniMagick::Image.open(full_path).width.to_i

    IMAGE_SIZES.each do |size|
      next unless size < original_width

      resized_path = path.sub(/\.(png|jpg)$/, "-#{size}w.\\1")
      full_resized_path = ".#{resized_path}"
      srcset << "#{resized_path} #{size}w"
      @site.static_files << Jekyll::StaticFile.new(@site, '.', File.dirname(full_resized_path), File.basename(full_resized_path))

      next if File.exist?(full_resized_path)

      image = MiniMagick::Image.open(full_path)
      image.resize("#{size}x#{size}>")
      image.write(full_resized_path)
    end

    unless srcset.blank?
      srcset << "#{path} #{original_width}w"
      node['srcset'] = srcset.join(', ')
    end

    node['loading'] = 'lazy'

    if path.end_with?('jpg')
      image = MiniMagick::Image.open(full_path)

      size = image.dimensions
      node['data-width'] = size[0]
      node['data-height'] = size[1]

      image.resize('1x1')
      if color = image.pixel_at(1, 1)
        node['style'] = "background-color:#{color.downcase}"
      end
    end
  end
end

Jekyll::Hooks.register :posts, :post_render do |post|
  ImageProcessor.new(post).process!
end
