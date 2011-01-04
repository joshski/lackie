# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "lackie"

Gem::Specification.new do |s|
  s.name        = 'lackie'
  s.version     = Lackie::VERSION
  s.authors     = ['Josh Chisholm']
  s.description = 'Automates remote applications using an HTTP middleman'
  s.summary     = "lackie-#{s.version}"
  s.email       = 'joshuachisholm@gmail.com'
  s.homepage    = 'http://github.com/joshski/lackie'

  s.add_dependency 'json', '~> 1.4.6'
  s.add_dependency 'rack', '~> 1.2.1'
  s.add_dependency 'rest-client', '~> 1.4.2'
  
  s.add_development_dependency 'rspec', '~> 2.2.0'
  s.add_development_dependency 'cucumber', '~> 0.10.0'
  s.add_development_dependency 'mongrel', '~> 1.1.5'
  #s.add_development_dependency 'relevance-rcov', '~> 0.9.2.1'
  s.add_development_dependency 'selenium-webdriver', '~> 0.1.2'
  
  s.rubygems_version  = "1.3.7"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {spec,features}/*`.split("\n")
  s.extra_rdoc_files  = ["README.rdoc"]
  s.require_path      = "lib"
end
