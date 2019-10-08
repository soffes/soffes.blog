require 'nokogiri'
require 'mini_magick'

class Jekyll::Document
  def assets_url
    "#{site.data['url']}/#{assets_path}"
  end

  def assets_path
    "assets/#{data['date'].strftime('%Y-%m-%d')}-#{data['slug']}/"
  end
end

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

class RewriteImages < Jekyll::Generator
  IMAGE_SIZES = [640, 1024]

  def generate(site)
    @site = site
    markdown_converter = @site.find_converter_instance(Jekyll::Converters::Markdown)

    site.posts.docs.each do |document|
      assets_url = document.assets_url
      document.content.gsub!(/(<img.*src=")(?!http)([^"]+\.(?:jpg|png|svg))(".*>)/, "\\1#{assets_url}\\2\\3")
      document.content.gsub!(/(<a.*href=")(?!http)([^"]+\.(?:jpg|png|svg))(".*>)/, "\\1#{assets_url}\\2\\3")
      document.content.gsub!(/!\[(.*)\]\((?!http)(.*)\)/, %(<img src="#{assets_url}\\2" alt="\\1">))

      if document.data['cover_image']
        path = document.assets_path + document.data['cover_image']
        document.data['cover_image'] = assets_url + document.data['cover_image']

        size = MiniMagick::Image.open(path).dimensions
        document.data['cover_image_width'] = size[0]
        document.data['cover_image_height'] = size[1]
      end

      doc = Nokogiri::HTML.fragment(document.content)
      doc.css('img').each do |node|
        next unless src = node['src']
        next if src.start_with?('http')
        next unless src.end_with?('png') || src.end_with?('jpg')

        path = ".#{src}"
        unless File.exist?(path)
          puts "--------> Missing image #{path}"
          next
        end

        # puts "        - Processing #{src}"
        process_image(node)
      end

      document.content = doc.to_html
    end

    puts '        - Rewrite Images'
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
      node['sizes'] = '80vw'
    end

    if path.end_with?('jpg')
      image = MiniMagick::Image.open(full_path)
      image.resize('1x1')
      if color = image.pixel_at(1, 1)
        node['style'] = "background-color:#{color.downcase}"
      end
    end
  end
end

