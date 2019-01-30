class RewriteTitle < Jekyll::Generator
  safe true

  REGEX = /(?:---\n[\s\w]*\n---\n)?(# (.*)\n\n)/.freeze

  def generate(site)
    site.posts.docs.each do |document|
      next unless title = document.content.match(REGEX)[2]
      document.content.gsub!(REGEX, '')
      document.data['title'] = title.to_s
    end
    puts '        - Rewrite Title'
  end
end
