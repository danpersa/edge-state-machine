require 'rubygems'
require 'bundler'
require 'bundler/gem_tasks'


Bundler::GemHelper.install_tasks
Bundler.setup

require 'rake'

begin
  require 'rspec/core/rake_task'
  desc 'Run RSpecs to confirm that all functionality is working as expected'
  RSpec::Core::RakeTask.new('spec') do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end
  task :default => :spec
rescue LoadError
  puts "Hiding spec tasks because RSpec is not available"
end