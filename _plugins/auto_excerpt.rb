require 'action_view'
require 'nokogiri'

class AutoExcerpts < Jekyll::Generator
  include ActionView::Helpers::TextHelper

  safe true
  priority :low

  def generate(site)
    @site = site

    site.posts.docs.each do |document|
      nodes = excerpt_for(document.content)
      document.data['excerpt'] = nodes.map { |e| e.to_html }.join

      text = nodes.map { |e| e.text }.join(' ').gsub(/\n/, ' ').gsub(/\s+/, ' ')
      document.data['excerpt_text'] = truncate(text, length: 150, separator: /\s/)
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
      next if block.name == 'h2' || block.name == 'h3' || block.name == 'div'
      nodes << block
      break if nodes.count == 3
    end
    nodes
  end

  def html_for(markdown)
    @_markdown ||= @site.find_converter_instance(Jekyll::Converters::Markdown)
    @_markdown.convert(markdown)
  end
end
