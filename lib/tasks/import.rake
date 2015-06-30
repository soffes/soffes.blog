require 'soffes/blog'
require 'soffes/blog/importer'

desc 'Start over'
task :clean do
  Soffes::Blog.redis.flushdb
  `rm -rf tmp`
end

desc 'Import from a fresh start'
task :import do
  importer = Soffes::Blog::Importer.new
  importer.import
end
