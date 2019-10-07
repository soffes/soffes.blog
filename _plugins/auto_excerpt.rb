require 'action_view'
require 'nokogiri'

Jekyll::Hooks.register :posts, :post_render do |post|
  processor = AutoExcerptProcessor.new(post)
  processor.process!
end

class AutoExcerptProcessor
  include ActionView::Helpers::TextHelper

  def initialize(document)
    @document = document
  end

  def process!
    nodes = excerpt_for(@document.content)
    @document.data['excerpt'] = nodes.map { |e| e.to_html }.join

    text = nodes.map { |e| e.text }.join(' ').gsub(/\n/, ' ').gsub(/\s+/, ' ')
    @document.data['excerpt_text'] = truncate(text, length: 150, separator: /\s/)
  end

  private

  def excerpt_for(html)
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
end
