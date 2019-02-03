require 'pygments'
require 'redcarpet'

class MarkdownRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    if language
      Pygments.highlight(code, lexer: language.to_sym)
    else
      "<pre>#{code}</pre>"
    end
  end
end

class Jekyll::Converters::Markdown::Custom
  OPTIONS = {
    no_intra_emphasis: true,
    tables: true,
    fenced_code_blocks: true,
    autolink: true,
    strikethrough: true,
    space_after_headers: true,
    superscript: true,
    with_toc_data: true,
    underline: true,
    highlight: true
  }

  def initialize(config)
    @processor = Redcarpet::Markdown.new(MarkdownRenderer, OPTIONS)
  end

  def convert(content)
    @processor.render(content)
  end
end
