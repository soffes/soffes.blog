# soffes.blog

[![Build Status](https://travis-ci.org/soffes/soffes.blog.svg?branch=master)](https://travis-ci.org/soffes/soffes.blog)

This is my blog. It's pretty simple. It stores all of the posts in Redis. They are updated via GitHub post-commit hook. My posts are stored [here](https://github.com/soffes/blog).


## Running Locally

Get the source

    $ git clone https://github.com/soffes/soffes.blog.git
    $ cd soffes.blog

Import my posts:

    $ rake import

Now you can start the server with Shotgun:

    $ bundle exec shotgun

Then open <http://localhost:9393> in your browser to see it running.


## TODO

- [x] Upload images from repo to S3 and edit `<img>` tags
- [x] Update style
- [x] Next & previous post links
- [ ] Modern meta markup
- [ ] Add tags to posts
