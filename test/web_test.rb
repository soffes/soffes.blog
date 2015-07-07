require 'test_helper'

module Soffes::Blog
  class WebTest < IntegrationTest
    def test_empty
      visit('/')
      assert page.has_content?('Hi')
    end

    def test_show
      PostsController.insert_post factory(key: 'pizza', html: '<p>This is delicious.</p>')
      visit('/pizza')
      assert page.has_content?('This is delicious.')
    end

    def test_show_redirect
      visit('/something-interesting/')
      assert_equal '/something-interesting', page.current_path
    end
  end
end
