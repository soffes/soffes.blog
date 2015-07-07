require 'test_helper'

module Soffes::Blog
  class WebTest < IntegrationTest
    def test_empty
      visit('/')
      assert page.has_content?('Hi')
    end

    def test_show
      factory(key: 'test', html: '<p>This is a test.</p>')
      visit('/test')
      assert page.has_content?('This is a test.')
    end

    def test_show_redirect
      factory(key: 'test')
      visit('/test/')
      assert_equal '/test', page.current_path
    end
  end
end
