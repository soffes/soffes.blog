class RewriteImages < Jekyll::Generator
  safe true

  REGEX = /!\[(.*)\]\((?!http)(.*)\)/.freeze

  def generate(site)
    site.posts.docs.each do |document|
      assets_path = assets_path_for(document)
      document.content.gsub!(REGEX, "![\\1](#{assets_path}\\2)")
    end
    puts '        - Rewrite Images'
  end

  private

  def assets_path_for(document)
    "/assets/#{document.data['date'].strftime('%Y-%m-%d')}-#{document.data['slug']}/"
  end
end
