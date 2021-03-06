require 'spec_helper'
require 'lackie/rack'

module Lackie
  module Rack
    describe Middleware do
      before do
        Lackie::JavaScript::Surrender.stub!(:new).and_return(mock("surrender", :script => "yowzer"))
        @app = mock("app")
        @env = mock("env")
        @middleware = Middleware.new(@app)
      end
      
      def request(options)
        @request = mock("Request: #{options.inspect}", options.merge(:user_agent => "some-user-agent"))
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
            get("/lackie/yield").should == [200, {"Content-Type"=>"text/javascript"},
              ['{"command":"foo()","id":1}'] ]
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
                  post("/lackie/eval", "bar()")
                  post("/lackie/result", { :id => 1, :value => "foo-result" }.to_json)
                  get("/lackie/result").should == [404, {'Content-Type' => 'text/plain'}, ["Not Found"]]
                end
                describe "then POST /lackie/result with the body 'bar-result'" do
                  describe "then GET /lackie/result" do
                    it "returns the value 'bar-result'" do
                      post("/lackie/eval", "foo()")
                      post("/lackie/eval", "bar()")
                      post("/lackie/result", { :id => 1, :value => "foo-result" }.to_json)
                      post("/lackie/result", { :id => 2, :value => "bar-result" }.to_json)
                      result_body = JSON.parse(get("/lackie/result").last.first)
                      result_body["value"].should == "bar-result"
                    end
                  end
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
      
      describe "POST /lackie/result with valid json in the body" do
        describe "then GET /lackie/result" do
          it "gets 'bar' as the response body" do
            post("/lackie/eval", "happy")
            json_string = { :value => "go lucky", :id => 1 }.to_json
            post("/lackie/result", json_string)
            result_body = JSON.parse(get("/lackie/result").last.first)
            result_body["id"].should == 1
            result_body["value"].should == "go lucky"
          end
        end
      end
      
      describe "POST /lackie/result with invalid json in the body" do
        describe "then GET /lackie/result" do
          it "returns 400 Bad Request" do
            post("/lackie/result", "crunch").should == [400, {"Content-Type"=>'text/plain'}, ["Bad Request"]]
          end
        end
      end
    end
  end
end