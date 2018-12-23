# soffes.blog

[![Build Status](https://travis-ci.org/soffes/soffes.blog.svg?branch=master)](https://travis-ci.org/soffes/soffes.blog)

This is my blog. It's pretty simple. It stores all of the posts in Redis. They are updated via GitHub post-commit hook. My posts are stored [here](https://github.com/soffes/blog).

## Running Locally

Get the source

```bash
$ git clone https://github.com/soffes/soffes.blog.git
$ cd soffes.blog
```

Install dependencies (you’ll need [Bundler](https://bundler.io) installed first):

```bash
$ bundle install
```

Import my posts:

```bash
$ rake import
```

Now you can start the server with Shotgun:

```bash
$ rake server
```

Then open [localhost:9393](http://localhost:9393) in your browser to see it running.
