require 'spec_helper'
require 'kl/primitives/symbols'

describe Kl::Primitives::Symbols do
  include Kl::Primitives::Symbols

  describe "intern" do
    it "returns boolean true for 'true'" do
      intern("true").should == true
    end

    it "returns boolean false for 'false'" do
      intern("false").should == false
    end

    it "returns the symbol corresponding to the string otherwise" do
      intern("abc-123").should == :"abc-123"
    end
  end
end

