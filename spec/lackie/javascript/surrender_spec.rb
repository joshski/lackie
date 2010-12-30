require 'spec_helper'
require 'lackie/javascript'

module Lackie
  module JavaScript
    describe Surrender do
      it "produces a javascript to zombify a remote browser" do
        Surrender.new.script.should =~ /window\.setInterval/
      end
      
      it "includes json2.js" do
        Surrender.new.script.should include("http://www.JSON.org/json2.js")
      end
    end
  end
end