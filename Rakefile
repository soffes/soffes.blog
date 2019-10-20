desc 'Import published posts'
task :import do
  unless File.directory?('tmp/blog')
    system 'mkdir -p tmp'
    system 'git clone https://github.com/soffes/blog tmp/blog'
  else
    system 'cd tmp/blog && git pull origin master && cd ..'
  end

  import_directory('tmp/blog/published', '_posts')
end

namespace :import do
  desc 'Import all local posts'
  task :local do
    import_local
    import_directory('tmp/blog/published', '_posts')
  end

  desc 'Import local drafts'
  task :drafts do
    import_local
    import_directory('tmp/blog/drafts', '_drafts')
  end
end

desc 'Build'
task :build do
  unless File.directory?('_posts')
    Rake::Task['import'].invoke
  end

  system 'bundle exec jekyll build --config _config.yml --trace'
end

task default: :build

desc 'Clean'
task :clean do
  system 'rm -rf tmp _posts _drafts _site assets .jekyll-cache'
end

desc 'Local server'
task :server do
  system 'bundle exec jekyll serve --config _config.yml --drafts --trace'
end

private

def import_directory(source, destination)
  unless File.directory?(source)
    abort "Missing directory `#{source}`"
  end

  system %(mkdir -p #{destination})
  system %(mkdir -p assets)
  system %(cp -r #{source}/* #{destination})

  Dir["#{destination}/*"].each do |dir|
    md = Dir["#{dir}/*.markdown"].first
    system %(mv #{md} #{dir}.md)

    if Dir.empty?(dir)
      system %(rm -rf #{dir})
    else
      system %(mv #{dir} assets)
    end
  end
end

def import_local
  unless File.directory?('../blog')
    abort 'Expected blog directory at `../blog/`'
  end

  system 'rm -rf tmp/blog'
  system 'mkdir -p tmp'
  system 'cp -r ../blog tmp/blog'
end
