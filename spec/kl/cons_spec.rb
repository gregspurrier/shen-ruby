require 'spec_helper'

describe Kl::Cons, '.list' do
  it 'returns Kl::EmptyList for an empty array' do
    Kl::Cons.list([]).should be_kind_of Kl::EmptyList
  end

  it 'constructs a nil-terminated list from a non-empty array' do
    Kl::Cons.list([1, 2, 3]).should == 
      Kl::Cons.new(1, Kl::Cons.new(2, Kl::Cons.new(3, Kl::EmptyList.instance)))
  end
end
