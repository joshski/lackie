require 'spec_helper'
require 'lackie/rack'

module Lackie
  module Rack
    describe Middleware do
      before do
        Lackie::JavaScript::Surrender.should_receive(:new).and_return(mock("surrender", :script => "yowzer"))
        @app = mock("app")
        @env = mock("env")
        @middleware = Middleware.new(@app)
      end
      
      def request(options)
        @request = mock("Request: #{options.inspect}", options)
        ::Rack::Request.stub!(:new).with(@env).and_return(@request)
        @middleware.call(@env)
      end
      
      def get(path)
        request(:path => path, :get? => true)
      end
      
      def post(path, body)
        request(:path => path, :get? => false, :body => mock("io", :read => body))
      end
      
      it "ignores GET requests with paths not beginning with /lackie/" do
        @app.should_receive(:call).with(@env).and_return(:result)
        get("else/where").should == :result
      end
      
      it "ignores POST requests with paths not beginning with /lackie/" do
        @app.should_receive(:call).with(@env).and_return(:result)
        post("over/yonder", "body").should == :result
      end
      
      describe "GET /lackie/surrender" do
        it "returns a javascript to zombify a remote browser" do
          get("/lackie/surrender").should == [200, {'Content-Type' => 'text/javascript'}, ["yowzer"]]
        end        
      end
      
      describe "POST /lackie/eval with the body 'foo()'" do
        describe "then GET /lackie/yield" do
          it "returns 'foo()' as the response body" do
            post("/lackie/eval", "foo()")
            get("/lackie/yield").should == [200, {"Content-Type"=>"text/javascript"}, ["foo()"]]
          end
          
          describe "then GET /lackie/yield" do
            it "returns not found" do
              post("/lackie/eval", "foo()")
              get("/lackie/yield")
              get("/lackie/yield").should == [404, {"Content-Type"=>"text/plain"}, ["Not Found"]]
            end
          end
          
          describe "then POST /lackie/eval with the body 'bar()'" do
            describe "then POST /lackie/result with the body 'foo-result'" do
              describe "then GET /lackie/result" do
                it "returns 404 not found" do
                  post("/lackie/eval", "foo()")
                  get("/lackie/yield")
                  post("/lackie/result", "foo-result")
                  post("/lackie/eval", "bar()")
                  get("/lackie/result").should == [404, {'Content-Type' => 'text/plain'}, ["Not Found"]]
                end
              end
            end
          end
        end
      end
      
      describe "GET /lackie/result (before POST /lackie/result)" do
        it "returns a 404 Not Found" do
          get("/lackie/result").should == [404, {'Content-Type' => 'text/plain'}, ["Not Found"]]
        end        
      end
      
      describe "POST /lackie/result with 'yippee'" do
        describe "then GET /lackie/result" do
          it "gets 'bar' as the response body" do
            post("/lackie/result", "'bar'")
            get("/lackie/result").should == [200, {"Content-Type"=>"application/json"}, ["'bar'"]]
          end
        end
      end
    end
  end
end