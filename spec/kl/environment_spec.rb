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

  describe 'evaluation of non-special forms' do
    it 'evaluates simple function application' do
      eval_str('(+ 1 2)').should == 3
    end

    it 'evaluates function arguments before application' do
      eval_str('(* (+ 1 2) (- 6 1))').should == 15
    end

    it 'supports currying' do
      eval_str('((+ 1) 2)').should == 3
      eval_str('(((+) 1) 2)').should == 3
    end
  end

  describe 'evaluation of lambda expressions' do
    it 'evaluates them to proc objects' do
      eval_str('(lambda X X)').should be_kind_of Proc
    end

    it 'allows them to be applied' do
      eval_str('((lambda X X) 37)').should == 37
      eval_str('((lambda X 42) ignore-me)').should == 42
    end

    it 'maintains lexical scoping' do
      # (let X 1
      #   (let Y 3
      #     (let X 7
      #       (+ X Y)
      eval_str('((lambda X 
                   ((lambda Y 
                      ((lambda X (+ X Y)) 
                        7))
                     3)) 
                   1)').should == 10
    end
  end

end
