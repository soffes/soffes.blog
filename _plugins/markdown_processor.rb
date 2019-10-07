require 'rouge'
require 'redcarpet'
require 'nokogiri'
require 'mini_magick'

class MarkdownRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    if language
      language = 'objective_c' if language == 'objective-c' || language == 'objc'
      %(<div class="highlight"><pre>#{Rouge.highlight(code, language, 'html')}</pre></div>)
    else
      "<pre>#{code}</pre>"
    end
  end
end

class Jekyll::Converters::Markdown::Custom
  IMAGE_SIZES = [320, 640, 1024, 2048]
  OPTIONS = {
    no_intra_emphasis: true,
    tables: true,
    fenced_code_blocks: true,
    autolink: true,
    strikethrough: true,
    space_after_headers: true,
    superscript: true,
    with_toc_data: true,
    underline: true,
    highlight: true
  }

  def initialize(config)
    @processor = Redcarpet::Markdown.new(MarkdownRenderer, OPTIONS)
  end

  def convert(content)
    html = @processor.render(content)

    doc = Nokogiri::HTML.fragment(html)
    unless (images = doc.css('article img')).blank?
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

      html = doc.to_html
    end

    html
  end

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

      next if File.exist?(full_resized_path)

      image = MiniMagick::Image.open(full_path)
      image.resize "#{size}x#{size}>"
      image.write(full_resized_path)
    end

    return if srcset.blank?

    node['srcset'] = srcset.join(', ')
    node['sizes'] = '80vw'
  end
end
