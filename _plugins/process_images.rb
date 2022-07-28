require "addressable/uri"
require "base64"
require "mini_magick"
require "nokogiri"

module MiniMagick
  # Extension on `MiniMagick::Image`
  class Image
    def pixel_at(x, y)
      run_command("convert", "#{path}[1x1+#{x.to_i}+#{y.to_i}]", "txt:").split("\n").each do |line|
        matches = /^0,0:.*(#[0-9a-fA-F]+)/.match(line)
        return matches[1] if matches
      end
      nil
    end
    # rubocop:enable Naming/MethodParameterName
  end
end

# Jekyll hook to process images
class ImageProcessor
  # 4.5", 4.0" (2x):            228w, 140w,  91w,  66w
  # 4.7", 5.8" (2x, 3x):        343w, 168w, 109w,  80w
  # 5.5", 6.1", 6.5" (2x, 3x):  382w, 137w, 122w,  90w
  # Deskop (1x, 2x, 3x):       1024w, 508w, 336w, 250w
  IMAGE_SIZES = [
    [
      {width: 1024, scales: [1, 2], max_width: 1024},
      {width: 382, scales: [2, 3], max_width: 414},
      {width: 343, scales: [2, 3], max_width: 375},
      {width: 228, scales: [2], max_width: 320}
    ],
    [
      {width: 508, scales: [1, 2], max_width: 1024},
      {width: 137, scales: [2, 3], max_width: 414},
      {width: 168, scales: [2, 3], max_width: 375},
      {width: 140, scales: [2], max_width: 320}
    ],
    [
      {width: 336, scales: [1, 2], max_width: 1024},
      {width: 122, scales: [2, 3], max_width: 414},
      {width: 109, scales: [2, 3], max_width: 375},
      {width: 91, scales: [2], max_width: 320}
    ],
    [
      {width: 250, scales: [1, 2], max_width: 1024},
      {width: 90, scales: [2, 3], max_width: 414},
      {width: 80, scales: [2, 3], max_width: 375},
      {width: 66, scales: [2], max_width: 320}
    ]
  ].freeze

  def initialize(post, should_process = true)
    @post = post
    @site = post.site
    @should_process = should_process
  end

  def process!
    return unless @should_process

    doc = Nokogiri::HTML.fragment(@post.output)
    doc.css("img").each do |node|
      next unless (src = node["src"])
      next if src.start_with?("http")
      next unless src.end_with?("png", "jpg")

      process_image(node)
    end

    if is_production?
      doc.css('meta[property="og:image"], meta[name="twitter:image"]').each do |node|
        url = Addressable::URI.parse(@site.config["cdn_url"])
        url.path = Addressable::URI.parse(node["content"]).path
        url.query = "w=512&dpr=2&auto=format,compress"
        node["content"] = url.to_s
      end
    end

    @post.output = doc.to_html
  end

  private

  def is_production?
    ENV["RACK_ENV"] == "production"
  end

  def process_image(node)
    src = node["src"]
    url = is_production? ? (@site.config["cdn_url"] + src) : src
    srcset = []
    sizes = []

    is_cover = node.parent["class"] == "cover"
    up = 1
    if node.parent.name == "photo-row"
      count = node.parent.css("img").count
      if count > 4
        puts "Error: #{@post.data["slug"]} has invalid photo-row"
      else
        up = count
      end
    end

    image_sizes = IMAGE_SIZES[up - 1]
    image_sizes.reverse_each do |size|
      # Remove this variant for covers on small phones since it gets pixelated.
      # Ideally, we'd have a separate set of image sizes just for covers, but this is fine for now.
      next if is_cover && size[:max_width] == 320

      size[:scales].reverse_each do |scale|
        srcset += ["#{url}?w=#{size[:width]}&dpr=#{scale}&auto=format,compress #{size[:width] * scale}w"]
      end

      sizes << if size[:max_width] == 1024
        "1024px"
      else
        "(max-width: #{size[:max_width]}px) #{size[:width]}px"
      end
    end


    if is_production?
      node["src"] = "#{url}?w=1024&dpr=2&auto=format,compress"
      node["srcset"] = srcset.join(",")
      node["sizes"] = sizes.join(",")
    end

    node["loading"] = "lazy" unless node["loading"]

    return unless src.end_with?("jpg")

    image = MiniMagick::Image.open(".#{src}")

    size = image.dimensions
    node["data-width"] = size[0]
    node["data-height"] = size[1]

    # Only do the backgrounds on production since it’s pretty slow
    return unless is_production?

    if is_cover
      image.resize("4x4")
      node["style"] =
        "background-image:url(data:image/png;base64,#{Base64.urlsafe_encode64(image.to_blob)});" \
        "background-repeat:no-repeat;background-size:cover"
    else
      image.resize("1x1")
      if (color = image.pixel_at(1, 1))
        node["style"] = "background-color:#{color.downcase}"
      end
    end
  end
end

Jekyll::Hooks.register :posts, :post_render do |post|
  ImageProcessor.new(post).process!
end
