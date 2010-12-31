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