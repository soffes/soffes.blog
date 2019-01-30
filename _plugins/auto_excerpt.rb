class AutoExcerpts < Jekyll::Generator
  safe true

  def generate(site)
    # site.posts.docs.each do |document|
    #   nodes = []
    #   doc.children.each do |block|
    #     next if block.to_html.strip.empty?
    #     next if block.name == 'h2' || block.name == 'h3'
    #     nodes << block
    #     break if nodes.count == 3
    #   end
    #   meta['excerpt_html'] = nodes.map { |e| e.to_html }.join
    #   meta['excerpt_text'] = nodes.map { |e| e.text }.join(' ')
    # end
    # puts '        - Auto Excerpts'
  end
end
