# blog.soff.es

This is my blog. It's pretty simple. It stores all of the posts in Redis. They are updated via GitHub post-commit hook. My posts are stored [here](https://github.com/soffes/blog).


## Running Locally

Get the source

    $ git clone https://github.com/soffes/blog.soff.es.git
    $ cd blog.soff.es

Import my posts:

    $ rake import

Now you can start the server with Foreman:

    $ bundle exec foreman start

Then open <http://localhost:5000> in your browser to see it running.


## TODO

- [x] Upload images from repo to S3 and edit `<img>` tags
- [ ] Update style
- [ ] Next & previous post links
- [ ] Modern meta markup
- [ ] Add tags to posts
