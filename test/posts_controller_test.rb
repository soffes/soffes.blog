require 'test_helper'

module Soffes::Blog
  class PostsControllerTest < Test
    def test_empty
      assert_equal 0, PostsController.posts.length
      assert_equal 0, PostsController.total_pages
    end

    def test_inserting
      assert PostsController.insert_post factory(key: 'test')
      assert_equal 'test', PostsController.posts.first['key']
    end

    def test_surrounding
      PostsController.insert_post factory(key: 'post-1', published_at: 1)
      PostsController.insert_post factory(key: 'post-2', published_at: 2)
      PostsController.insert_post factory(key: 'post-3', published_at: 3)
      PostsController.insert_post factory(key: 'post-4', published_at: 4)
      PostsController.insert_post factory(key: 'post-5', published_at: 5)

      assert_nil PostsController.older_post('post-1')
      assert_equal 'post-2', PostsController.newer_post('post-1')['key']

      assert_equal 'post-2', PostsController.older_post('post-3')['key']
      assert_equal 'post-4', PostsController.newer_post('post-3')['key']

      assert_equal 'post-4', PostsController.older_post('post-5')['key']
      assert_nil PostsController.newer_post('post-5')
    end

    private

    def factory(key:, title: key, html: '<p>Hi</p>', published_at: Time.now.to_i)
      {
        'key' => key,
        'title' => title,
        'html' => html,
        'published_at' => published_at
      }
    end
  end
end
