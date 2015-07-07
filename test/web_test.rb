require 'test_helper'

module Soffes::Blog
  class WebTest < IntegrationTest
    def test_empty
      visit('/')
      assert page.has_content?('Hi')
    end
  end
end
