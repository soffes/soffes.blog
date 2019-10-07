Jekyll::Hooks.register :posts, :post_render do |post|
  processor = ImageProcessor.new(post)
  processor.process!
end

class ImageProcessor
  SIZES = [320, 640, 1024, 2048].freeze
  def initialize(document)
    @document = document
  end

  def process!
    doc = Nokogiri::HTML.fragment(@document.output)
    images = doc.css('article img')
    return if images.blank?

    images.each do |node|
      src = node['src']
      next if src.start_with?('http')
      next unless src.end_with?('png') || src.end_with?('jpg')

      path = ".#{src}"
      unless File.exist?(path)
        puts "Missing image: #{path}"
        next
      end

      process_image(node)
    end

    @document.output = doc.to_html
  end

  private

  def process_image(node)
    path = node['src']
    full_path = ".#{path}"
    srcset = []
    original_width = MiniMagick::Image.open(full_path).width.to_i

    SIZES.each do |size|
      next unless size < original_width

      resized_path = path.sub(/\.(png|jpg)$/, "-#{size}w.\\1")
      full_resized_path = ".#{resized_path}"
      srcset << "#{resized_path} #{size}w"

      image = MiniMagick::Image.open(full_path)
      image.resize "#{size}x#{size}>"
      image.write(full_resized_path)
    end

    return if srcset.blank?

    node['srcset'] = srcset.join(', ')
    node['sizes'] = '80vw'
  end
end
