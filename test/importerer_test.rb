require 'test_helper'

module Soffes::Blog
  class ImporterTest < Test
    def test_importing
      importer = Importer.new(local_posts_path: 'test/fixtures/repo', update_posts: false, bucket_name: 'test')
      importer.import

      slugs = PostsController.posts.map { |post| post['key'] }
      assert_equal %w{nsregularexpression-notes personal-sam the-motorola-rokr}, slugs
    end
  end
end
