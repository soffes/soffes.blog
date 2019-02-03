require 'nokogiri'

class AutoExcerpts < Jekyll::Generator
  safe true
  priority :low

  def generate(site)
    @site = site

    site.posts.docs.each do |document|
      document.data['excerpt'] = excerpt_for(document.content)
    end

    puts '        - Auto Excerpts'
  end

  private

  def excerpt_for(markdown)
    html = html_for(markdown)
    doc = Nokogiri::HTML.fragment(html)

    nodes = []
    doc.children.each do |block|
      next if block.to_html.strip.empty?
      next if block.name == 'h2' || block.name == 'h3'
      nodes << block
      break if nodes.count == 3
    end

    nodes.map { |e| e.to_html }.join
  end

  def html_for(markdown)
    @_markdown ||= @site.find_converter_instance(Jekyll::Converters::Markdown)
    @_markdown.convert(markdown)
  end
end
