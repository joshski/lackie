require 'spec_helper'
require 'lackie/javascript'

module Lackie
  describe RemoteControl do
    before(:each) do
      Time.stub!(:now).and_return(mock("now", :to_i => "cachebust"))
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
      RestClient.stub!(:get).with("http://host:555/lackie/result?cachebust").and_return {
        responses.shift.call
      }
      @rc.exec("foo").should == "bar"
      responses.should be_empty
    end
    
    it "cache-busts calls to GET /lackie/result" do
      now = mock("now")
      Time.should_receive(:now).and_return(now)
      now.should_receive(:to_i).and_return("letmego")
      RestClient.should_receive(:get).with("http://host:555/lackie/result?letmego").and_return(
        mock("response", :body => '{"value":"123"}')
      )
      @rc.exec("foo")
    end
    
    it "waits for a default number of seconds" do
      @poller.should_receive(:await).with("result of command:\nfoo", {}).and_yield
      @rc.exec("foo")
    end
    
    it "waits for an ad-hoc number of seconds" do
      @poller.should_receive(:await).with("result of command:\nbar", :timeout_seconds => 666).and_yield
      @rc.exec("bar", :timeout_seconds => 666)
    end
    
    it "deserializes json results" do
      RestClient.should_receive(:get).and_return(mock("response", :body => '{"value":666}'))
      @rc.log("oops").should == 666
    end
    
    it "rethrows json errors" do
      RestClient.should_receive(:get).and_return(mock("response", :body => '{"error":"oops"}'))
      lambda { @rc.log("oops") }.should raise_error("oops")
    end
    
    it "raises when sending a command fails" do
      RestClient.should_receive(:post).with("http://host:555/lackie/eval", 'foo').and_raise "oops"
      begin
        @rc.exec("foo")
        fail "never raised"
      rescue => e
        e.message.should =~ /have you started a lackie server?/
      end
    end
    
    describe "#await" do
      it "does not raise if the value eventually matches the block" do
        responses = ["bar", "foo"].map do |result|
          mock("stub_result_response", :body => { :value => result }.to_json)
        end
        RestClient.stub!(:get).with("http://host:555/lackie/result?cachebust").and_return {
          responses.shift
        }
        lambda {
          @rc.await("script") { |value| value == "foo" }
        }.should_not raise_error
      end
      
      it "raises if the value never matches the block" do
        RestClient.stub!(:get).with("http://host:555/lackie/result?cachebust").and_return {
          mock("stub_result_response", :body => '{"value":"oopsie"}')
        }
        begin
          @rc.await("script") { |value| value == "bar" }
        rescue Lackie::AwaitError => e
          e.message.should =~ /oopsie/
        end
      end
      
      it "accepts an optional total number of seconds to wait" do
        @poller.should_receive(:await).with("result matching expression: script", :timeout_seconds => 333)
        @rc.await("script", :timeout_seconds => 333) { |value| value == "bar" }
      end
    end
  end
end