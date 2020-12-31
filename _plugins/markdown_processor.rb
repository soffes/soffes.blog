# frozen_string_literal: true

require 'rouge'
require 'redcarpet'

class MarkdownRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    if language
      language = 'objective_c' if %w[objective-c objc].include?(language)
      %(<div class="highlight"><pre>#{Rouge.highlight(code, language, 'html')}</pre></div>)
    else
      "<pre>#{code}</pre>"
    end
  end
end

module Jekyll
  module Converters
    class Markdown
      class Custom
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
        }.freeze

        def initialize(_config)
          @processor = Redcarpet::Markdown.new(MarkdownRenderer, OPTIONS)
        end

        def convert(content)
          @processor.render(content)
        end
      end
    end
  end
end
