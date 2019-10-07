# Sam’s Blog

This is my blog. It’s built on top of [Jekyll](https://jekyllrb.com) with lots of custom things because I have overly strong opinions about Markdown.

My posts are stored [in a different repo](https://github.com/soffes/blog). I really like writing my posts the way I want to write them. I don’t want to have anything specific to Jekyll in there. All of the custom things help convert things from how the posts are stored to what Jekyll wants.

## Running Locally

Get the source

```bash
$ git clone https://github.com/soffes/soffes.blog.git
$ cd soffes.blog
```

You’ll need Image Magick first. You can install this with [Homebrew](https://brew.sh):

```bash
$ brew install imagemagick
```

Install the Ruby dependencies (you’ll need [Bundler](https://bundler.io) installed first):

```bash
$ bundle install
```

Now you can import my posts and start the server:

```bash
$ rake import
$ rake server
```

Now open [localhost:4000](http://localhost:4000) in your browser to see it running.
