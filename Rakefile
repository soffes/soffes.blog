desc 'Import posts'
task :import => :clean do
  `rm -rf _posts assets`
  `mkdir -p assets`

  unless File.directory?('tmp/blog')
    `mkdir -p tmp`
    `git clone https://github.com/soffes/blog tmp/blog`
  else
    `cd tmp/blog && git pull origin master && cd ..`
  end

  import_directory('tmp/blog/published', '_posts')
  # import_directory('tmp/blog/drafts', '_drafts')
end

desc 'Build'
task :build => :import do
  `bundle exec jekyll build --config _config.yml`
end

desc 'Clean'
task :clean do
  `rm -rf _posts _drafts _site assets`
end

desc 'Local server'
task :server => :import do
  `bundle exec jekyll serve`
end

private

def import_directory(source, destination)
  `cp -r "#{source}" "#{destination}"`

  Dir.chdir(destination) do
    Dir['*'].each do |dir|
      md = Dir["#{dir}/*.markdown"].first
      `mv "#{md}" "#{dir}.md"`

      if Dir.empty?(dir)
        `rm -rf "#{dir}"`
      else
        `mv "#{dir}" "../assets/"`
      end

      `rm -rf "#{dir}"`
    end
  end
end
