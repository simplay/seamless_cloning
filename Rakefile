require "bundler/gem_tasks"
require "rake/testtask"
require 'rake/extensiontask'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::ExtensionTask.new 'solvers' do |ext|
  ext.name    = 'fast_poisson_solver'
  ext.lib_dir = 'lib/seamless_cloning'
end

task :default => :test
