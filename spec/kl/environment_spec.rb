require 'spec_helper'

describe Kl::Environment do
  def eval_str(str)
    form = Kl::Reader.new(StringIO.new(str)).next
    @env.__eval(form)
  end

  before(:each) do
    @env = Kl::Environment.new
  end

  describe 'evaluation of atoms' do
    it 'evaluates symbols to themselves' do
      eval_str('foo').should == :foo
      eval_str('foo-bar-<baz>').should == "foo-bar-<baz>".to_sym
    end

    it 'evaluates strings to themselves' do
      eval_str('"foo"').should == 'foo'
      eval_str('"foo #{bar} \'baz"').should == 'foo #{bar} \'baz'
      eval_str('"\\"').should == '\\'
    end

    it 'evaluates numbers to themselves' do
      eval_str('1').should == 1
      eval_str('-1.7').should == -1.7
    end

    it 'evaluates booleans to themselves' do
      eval_str('true').should == true
      eval_str('false').should == false
    end
  end
end
