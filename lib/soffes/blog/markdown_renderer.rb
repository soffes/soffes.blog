require 'redcarpet'
require 'pygments.rb'

module Soffes
  module Blog
    class MarkdownRenderer < Redcarpet::Render::HTML
      def block_code(code, language)
        if language
          Pygments.highlight(code, lexer: language.to_sym)
        else
          "<pre>#{code}</pre>"
        end
      end
    end
  end
end
