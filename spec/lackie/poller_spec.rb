require 'spec_helper'
require 'lackie/poller'

module Lackie
  describe Poller do
    it "sleeps for a sepecified number of seconds between yields, until the block returns true" do
      Kernel.should_receive(:sleep).with(0.666).exactly(:twice)
      return_values = [false, false, true]
      Poller.new(:interval_seconds => 0.666).await("foo") do
        return_values.shift
      end
      return_values.should be_empty
    end
    
    it "gives up after a specified number of seconds" do
      Kernel.stub!(:sleep)
      poller = Poller.new(:timeout_seconds => 2.5)
      lambda {
        poller.await("foo") do
          false
        end
      }.should raise_error("Timed out after 2.5 seconds awaiting foo")
    end
    
    it "uses a different sleeper when Kernel is not convenient" do
      sleeper = mock("sleeper")
      sleeper.should_receive(:sleep).with(0.999).exactly(:twice)
      return_values = [false, false, true]
      Poller.new(:interval_seconds => 0.999, :sleeper => sleeper).await("foo") do
        return_values.shift
      end
    end
  end
end