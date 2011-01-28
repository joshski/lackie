require 'spec_helper'
require 'lackie/rack'

module Lackie
  module Rack
    describe Middleware, "with a logger" do
      before do
        Lackie::JavaScript::Surrender.stub!(:new).and_return(mock("surrender", :script => "yowzer"))
        @app = mock("app")
        @env = mock("env")
        @logger = mock("logger", :log => true)
        @middleware = Middleware.new(@app, @logger)
      end
      
      def request(options)
        @request = mock("Request: #{options.inspect}", options)
        ::Rack::Request.stub!(:new).with(@env).and_return(@request)
        @middleware.call(@env)
      end
      
      def get(path, options)
        request(options.merge({ :path => path, :get? => true }))
      end
      
      def post(path, body)
        request(:path => path, :get? => false, :body => mock("io", :read => body))
      end
      
      it "logs the surrendered user agent" do
        @logger.should_receive(:log).with("surrendered to some-browser")
        get("/lackie/surrender", :user_agent => "some-browser")
      end
      
      it "logs commands with ids" do
        @logger.should_receive(:log).with("eval {\"command\":\"foo\",\"id\":1}")
        post("/lackie/eval", "foo")
      end
      
      it "logs results with ids" do
        post("/lackie/eval", "bar")
        @logger.should_receive(:log).with("result {\"id\":1,\"value\":\"bar\"}")
        post("/lackie/result", "{\"id\":1,\"value\":\"bar\"}")
      end
    end
    
    describe SimpleLogger do
      it "logs using Kernel.puts" do
        Kernel.should_receive(:puts).with("yo").once
        SimpleLogger.new.log("yo")
      end
    end
  end
end