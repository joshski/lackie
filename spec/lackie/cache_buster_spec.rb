require 'spec_helper'
require 'lackie/cache_buster'

module Lackie
  describe CacheBuster do
    it "returns unique strings" do
      (1..99).map { |i| CacheBuster.unique_string }.uniq.size.should == 99
    end
  end
end