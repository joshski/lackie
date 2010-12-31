require 'spec_helper'
require 'lackie/javascript'

module Lackie
  describe RemoteControl do
    before(:each) do
      @poller = Poller.new(:sleeper => mock("sleeper", :sleep => true))
      Poller.stub!(:new).and_return(@poller)
      @rc = RemoteControl.new("host", 555, @poller)
      RestClient.stub!(:post)
      RestClient.stub!(:get).and_return(mock("response", :body => '{"value":"123"}'))
    end
    
    it "sends log commands as POST /lackie/eval" do
      RestClient.should_receive(:post).with("http://host:555/lackie/eval", 'Lackie.log("OK")')
      @rc.log("OK")
    end
    
    it "sends execute 'X' commands as POST /lackie/eval with the body 'X'" do
      RestClient.should_receive(:post).with("http://host:555/lackie/eval", 'X')
      @rc.exec("X")
    end
    
    it "polls for results via GET /lackie/result" do
      responses = [
        lambda { raise RestClient::ResourceNotFound },
        lambda { mock("poll_response", :body => '{"value":"bar"}') }
      ]
      RestClient.stub!(:get).with("http://host:555/lackie/result").and_return {
        responses.shift.call
      }
      @rc.exec("foo").should == "bar"
      responses.should be_empty
    end
    
    it "deserializes json results" do
      RestClient.should_receive(:get).and_return(mock("response", :body => '{"value":666}'))
      @rc.log("oops").should == 666
    end
    
    it "rethrows json errors" do
      RestClient.should_receive(:get).and_return(mock("response", :body => '{"error":"oops"}'))
      lambda { @rc.log("oops") }.should raise_error("oops")
    end
  end
end