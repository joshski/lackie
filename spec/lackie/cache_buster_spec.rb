require 'spec_helper'
require 'lackie/cache_buster'

module Lackie
  describe CacheBuster do
    it "produces unique strings" do
      (1..99).map { |i| CacheBuster.unique_string }.uniq.size.should == 99
    end
    
    it "produces strings that include the current time" do
      Time.should_receive(:now).and_return("332211")
      CacheBuster.unique_string.should =~ /332211/
    end
  end
end