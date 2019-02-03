require 'strscan'

class AutoExcerpts < Jekyll::Generator
  H1_REGEX = /^# .*$\n\n/

  safe true
  priority :low

  def generate(site)
    markdown = site.find_converter_instance(Jekyll::Converters::Markdown)
    site.posts.docs.each do |document|
      scanner = StringScanner.new(document.content)
      scanner.scan_until H1_REGEX

      3.times do
        scanner.scan_until /^\n/
      end

      excerpt = document.content[0...scanner.charpos]
      document.data['excerpt'] = markdown.convert(excerpt)
    end

    puts '        - Auto Excerpts'
  end
end
