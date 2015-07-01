require 'soffes/blog'

desc 'Start over'
task :clean do
  Soffes::Blog.redis.flushdb
  `rm -rf tmp`
end

desc 'Import from a fresh start'
task :import do
  require 'soffes/blog/importer'
  importer = Soffes::Blog::Importer.new
  importer.import
end
