$:.unshift(File.dirname(__FILE__) + '/../../lib')
$:.unshift(File.dirname(__FILE__))

require 'rack'
require 'mongrel'
require 'selenium-webdriver'
require 'lackie'
require 'lackie/rack'
require 'example_app'

module LackieWorld
  def remote_control
    Lackie::RemoteControl.new(host, port)
  end
  
  def browse_example_app
    web_driver.get "http://#{host}:#{port}/example_app/app.html"
  end
  
  private
  
  def host
    "localhost"
  end
  
  def port
    6663
  end
  
  def web_driver
    @@web_driver ||= begin
      start_server
      driver = Selenium::WebDriver.for :firefox
      at_exit { driver.close }
      driver
    end
  end
  
  def start_server
    rack_server = nil
    rack_thread = Thread.new do
      ::Rack::Handler::Mongrel.run(ExampleApp.build, :Host => host, :Port => port) do |server|
        rack_server = server
      end
    end
    at_exit do
      rack_server.stop
      rack_thread.kill
    end
    sleep 0.05 while rack_server.nil?
  end
end

World(LackieWorld)