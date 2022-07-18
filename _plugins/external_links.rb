require "addressable/uri"
require "nokogiri"

# Jekyll hook to add targets to external links
class ExternalLinksProcessor
  def initialize(post)
    @post = post
    @site = post.site
    @blog_host = Addressable::URI.parse(@site.config["url"]).host
  end

  def process!
    @post.output = process(@post.output)
    @post.data["excerpt"] = process(@post.data["excerpt"])
  end

  private

  def process(html)
    doc = Nokogiri::HTML.fragment(html)
    doc.css("a").each do |node|
      next unless (href = node["href"])
      next unless (uri = Addressable::URI.parse(href))
      next if !uri.host || uri.host == @blog_host

      node["target"] = "_blank"
      node["rel"] = "noopener"
    end

    doc.to_html
  end
end

Jekyll::Hooks.register :posts, :post_render do |post|
  ExternalLinksProcessor.new(post).process!
end
