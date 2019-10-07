require 'dimensions'

class RewriteImages < Jekyll::Generator
  safe true

  def generate(site)
    @site = site

    site.posts.docs.each do |document|
      assets_url = assets_url_for(document)
      document.content.gsub!(/!\[(.*)\]\((?!http)(.*)\)/, "![\\1](#{assets_url}\\2)")
      document.content.gsub!(/(<img.*src=")(?!http)([^"]+\.(?:jpg|png|svg))(".*>)/, "\\1#{assets_url}\\2\\3")
      document.content.gsub!(/(<a.*href=")(?!http)([^"]+\.(?:jpg|png|svg))(".*>)/, "\\1#{assets_url}\\2\\3")

      if document.data['cover_image']
        path = assets_path_for(document) + document.data['cover_image']
        document.data['cover_image'] = assets_url + document.data['cover_image']

        size = Dimensions.dimensions(path)
        document.data['cover_image_width'] = size[0]
        document.data['cover_image_height'] = size[1]
      end
    end

    puts '        - Rewrite Images'
  end

  private

  def assets_url_for(document)
    "#{@site.data['url']}/#{assets_path_for(document)}"
  end

  def assets_path_for(document)
    "assets/#{document.data['date'].strftime('%Y-%m-%d')}-#{document.data['slug']}/"
  end
end
