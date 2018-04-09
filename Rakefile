require "bundler/gem_tasks"
require "rake/testtask"
require 'rake/extensiontask'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::ExtensionTask.new 'seamless_cloning' do |ext|
  ext.name    = 'seamless_cloning'
  ext.lib_dir = File.join('lib', 'seamless_cloning')
  ext.config_options = '--with-cflags="-std=c99"'
end

task :default => :test
