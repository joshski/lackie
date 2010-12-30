$:.unshift(File.dirname(__FILE__) + '/../../lib')
$:.unshift(File.dirname(__FILE__))

require 'lackie/rack'
require 'example_app'

run ExampleApp.build