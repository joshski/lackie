lib = File.dirname(__FILE__)
$:.unshift(lib) unless $:.include?(lib) || $:.include?(File.expand_path(lib))

module Lackie
  VERSION = '0.1.0'
end

require 'lackie/remote_control'