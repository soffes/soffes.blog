require "action_view"
require "nokogiri"

# Jekyll generator to create excepts for posts
class AutoExcerpts < Jekyll::Generator
  include ActionView::Helpers::TextHelper

  OMITTED_TAGS = %w[h2 h3 div photo-gallery].freeze

  safe true
  priority :low

  def generate(site)
    @site = site

    site.posts.docs.each do |document|
      nodes = excerpt_for(document.content)
      document.data["excerpt"] = nodes.map(&:to_html).join

      text = nodes.map(&:text).join(" ").tr("\n", " ").gsub(/\s+/, " ")
      document.data["excerpt_text"] = truncate(text, length: 150, separator: /\s/)
    end

    puts "        - Auto Excerpts"
  end

  private

  def excerpt_for(markdown)
    html = html_for(markdown)
    doc = Nokogiri::HTML.fragment(html)

    nodes = []
    doc.children.each do |block|
      next if block.to_html.strip.empty?
      next if OMITTED_TAGS.include?(block.name)
      next if block.children.first && OMITTED_TAGS.include?(block.children.first.name)

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
