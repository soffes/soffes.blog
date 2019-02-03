require 'json'

class JsonFeedTag < Liquid::Tag
  def render(context)
    site = context['site']
    feed = {
      version: 'https://jsonfeed.org/version/1',
      title: site['title'],
      description: 'This is my blog.',
      home_page_url: 'https://soffes.blog/',
      feed_url: 'https://soffes.blog/feeds/json',
      icon: 'https://soffes.blog/icon.png',
      favicon: 'https://soffes.blog/favicon.png',
      author: {
        name: 'Sam Soffes',
        url: 'https://soff.es/',
        avatar: 'https://soffes-assets.s3.amazonaws.com/images/Sam-Soffes.jpg'
      }
    }

    feed[:items] = site['posts'].map do |post|
      url = "https://soffes.blog/#{post['permalink']}"
      item = {
        id: url,
        url: url,
        title: post['title'],
        content_html: post.content,
        date_published: Time.at(post.date).to_datetime.rfc3339
      }

      if (tags = post['tags']) && !tags.empty?
        item[:tags] = tags
      end

      if cover_image = post.data['cover_image']
        item['banner_image'] = cover_image
      end

      item
    end

    feed.to_json
  end
end

Liquid::Template.register_tag('json_feed', JsonFeedTag)
