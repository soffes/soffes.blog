desc "Import published posts"
task :import do
  if File.directory?("tmp/blog")
    sh "cd tmp/blog && git pull origin main && cd .."
  else
    sh "mkdir -p tmp"
    sh "git clone https://github.com/soffes/blog tmp/blog"
  end

  import_directory("tmp/blog/published", "_posts")
end

namespace :import do
  desc "Import all local posts"
  task :local do
    import_local
    import_directory("tmp/blog/published", "_posts")
  end

  desc "Import local drafts"
  task :drafts do
    import_local
    import_directory("tmp/blog/drafts", "_drafts")
  end
end

desc "Build"
task :build do
  Rake::Task["import"].invoke unless File.directory?("_posts")

  sh "npm run build && bundle exec jekyll build --config _config.yml --trace"
end

task default: :build

desc "Clean"
task :clean do
  system "rm -rf tmp _posts _drafts _site assets .jekyll-cache js"
end

desc "Local server"
task :server do
  sh "npm run build && bundle exec jekyll serve --config _config.yml --drafts --trace"
end

namespace :lint do
  desc "Lint Ruby"
  task :ruby do
    sh "bundle exec standardrb"
  end

  desc "Lint YAML"
  task :yaml do
    if `which yamllint`.chomp.empty?
      abort "yamllint is not installed. Install it with `pip3 install yamllint`."
    end

    sh "yamllint -c .yamllint.yml ."
  end
end

desc "Run all linters"
task lint: %i[lint:ruby lint:yaml]

private

def import_directory(source, destination)
  abort "Missing directory `#{source}`" unless File.directory?(source)

  system %(mkdir -p #{destination})
  system %(mkdir -p assets)
  system %(cp -r #{source}/* #{destination})

  limit = ENV["LIMIT"]
  Dir["#{destination}/*"].reverse.each_with_index do |dir, i|
    if limit && i >= limit.to_i
      system %(rm -rf #{dir})
      next
    end

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
  abort "Expected blog directory at `../blog/`" unless File.directory?("../blog")

  system "rm -rf tmp/blog"
  system "mkdir -p tmp"
  system "cp -r ../blog tmp/blog"
end
