class DefaultLayout < Jekyll::Generator
  safe true

  def generate(site)
    site.posts.docs.each do |document|
      next if document.to_liquid.key? 'layout'
      document.data['layout'] = 'post'
    end
    puts '        - Default Layout'
  end
end
