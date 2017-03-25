require 'test_helper'

module Soffes::Blog
  class WebTest < IntegrationTest
    def test_empty
      visit '/'
      assert_equal 200, page.status_code
      assert page.has_content?('Hi')
    end

    def test_show
      PostsController.insert_post factory(key: 'pizza', html: '<p>This is delicious.</p>')
      visit '/pizza'
      assert_equal 200, page.status_code
      assert page.has_content?('This is delicious.')
    end

    def test_show_redirect
      visit '/something-interesting/'
      assert_equal '/something-interesting', page.current_path
    end

    def test_sitemap
      PostsController.insert_post factory(key: 'pizza', html: '<p>This is delicious.</p>')
      visit '/sitemap.xml'
      assert_equal 200, page.status_code
      assert page.has_content?('https://soffes.blog/pizza')

      # Validate
      schema = Nokogiri::XML::Schema(File.read('test/resources/sitemap.xsd'))
      validation_errors = schema.validate(Nokogiri::XML(page.body))
      assert_equal 0, validation_errors.length
    end

    def test_page_redirect
      visit '/page/2'
      assert_equal '/2', page.current_path
    end
  end
end
