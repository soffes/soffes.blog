require 'rubygems'
require 'bundler'
Bundler.require

$LOAD_PATH.unshift 'lib'
require 'soffes'

Dir.glob('lib/tasks/*.rake').each do |task|
  import task
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc 'Start development server'
task :server do
  system 'bundle exec shotgun'
end
