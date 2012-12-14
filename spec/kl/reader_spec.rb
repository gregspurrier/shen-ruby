require 'spec_helper'

describe Kl::Reader do
  def reader(str)
    Kl::Reader.new(StringIO.new(str))
  end

  describe 'Reading lists' do
    it 'reads () as an empty list' do
      reader('()').next.should be_kind_of Kl::EmptyList
    end

    it 'reads a list as a single expression' do
      list = reader('(1 2 3)').next
      list.should == Kl::Cons.list([1, 2, 3])
    end

    it 'supports nested lists' do
      list = reader('(1 (2 (3) ()))').next
      list.should == Kl::Cons.list([1, 
                                    Kl::Cons.list([2, 
                                                   Kl::Cons.list([3]),
                                                   Kl::EmptyList.instance])])
    end
  end

  describe 'Reading booleans' do
    it 'reads true as true' do
      reader('true').next.should == true
    end

    it 'reads false as false' do
      reader('false').next.should == false
    end
  end
end
