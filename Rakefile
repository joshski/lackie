require 'rake'
require 'rspec/core/rake_task'

desc  "Run all specs with rcov"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = %w{--exclude gems\/,spec\/,features\/}
end

desc  "Run all specs, then all features"
task :default do
  system("rspec spec && cucumber features")
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "lackie"
    gemspec.summary = "Automates remote applications using an HTTP middleman"
    gemspec.description = "Automates remote applications using an HTTP middleman"
    gemspec.email = "joshuachisholm@gmail.com"
    gemspec.homepage = "http://github.com/joshski/lackie"
    gemspec.authors = ["Josh Chisholm"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end