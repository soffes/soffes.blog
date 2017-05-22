feed = {
  version: 'https://jsonfeed.org/version/1',
  title: 'Hi, I’m Sam',
  description: 'This is my blog. Enjoy.',
  home_page_url: 'https://soffes.blog/',
  feed_url: 'https://soffes.blog/feed.json',
  icon: 'https://soffes.blog/icon.png',
  favicon: 'https://soffes.blog/favicon.png',
  author: {
    name: 'Sam Soffes',
    url: 'https://soff.es/',
    avatar: 'https://soffes-assets.s3.amazonaws.com/images/Sam-Soffes.jpg'
  }
}

# TODO: next_url

feed[:items] = posts.map do |post|
  # TODO: content_text, summary, image, tags
  url = "https://soffes.blog/#{post['key']}"
  item = {
    id: url,
    url: url,
    title: post['title'],
    content_html: post['html'],
    date_published: post['published_at'].to_datetime.rfc3339
  }

  item['banner_image'] = post['cover_image'] if post['cover_image']

  item
end
