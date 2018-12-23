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

desc 'Import local posts without images'
task :'import:local' do
  require 'soffes/blog/importer'
  importer = Soffes::Blog::Importer.new(
    local_posts_path: '../blog',
    update_posts: false,
    bucket_name: 'soffes-blog',
    use_s3: false
  )
  importer.import
end

desc 'Import drafts without images'
task :'import:local_drafts' do
  require 'soffes/blog/importer'
  importer = Soffes::Blog::Importer.new(
    local_posts_path: '../blog',
    update_posts: false,
    include_drafts: true,
    bucket_name: 'soffes-blog',
    use_s3: false
  )
  importer.import
end
