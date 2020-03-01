require 'nokogiri'

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

    node.name = 'picture'
    node.attributes.keys.each { |name| node.remove_attribute(name) }

    url = @site.config['cdn_url'] + src

    sizes = IMAGE_SIZES.dup
    smallest = sizes.pop
    sizes.each do |size|
      source = Nokogiri::XML::Node.new('source', node.document)
      source['srcset'] ="#{url}?w=#{size} 1x,#{url}?w=#{size}&dpr=2 2x, #{url}?w=#{size}&dpr=3 3x"
      source['media'] = "(min-width: #{size}px)"
      node.add_child(source)
    end

    img = Nokogiri::XML::Node.new('img', node.document)
    img['src'] = "#{url}?w=#{smallest}"
    img['srcset'] ="#{url}?w=#{smallest} 1x,#{url}?w=#{smallest}&dpr=2 2x, #{url}?w=#{smallest}&dpr=3 3x"
    node.add_child(img)
  end
end

Jekyll::Hooks.register :posts, :post_render do |post|
  ImageProcessor.new(post).process!
end
