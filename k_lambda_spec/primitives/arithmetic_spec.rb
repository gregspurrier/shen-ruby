require 'spec_helper'

describe 'Primitives for Arithmetic' do
  describe '+' do
    it 'adds its arguments' do
      kl_eval('(+ 1 2)').should == 3
    end

    it 'returns an integer when both arguments are integers' do
      kl_eval('(+ 1 2)').should be_kind_of Fixnum
    end

    it ('returns a real when either argument is a real') do
      kl_eval('(+ 1.0 2)').should be_kind_of Float
      kl_eval('(+ 1 2.0)').should be_kind_of Float
    end

    include_examples 'argument types', %w(+ 1 2),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(+ 1 2)
    include_examples 'partially-applicable function', %w(+ 1 2)
  end

  describe '-' do
    it 'subtracts its second argument from its first' do
      kl_eval('(- 3 2)').should == 1
    end

    it 'returns an integer when both arguments are integers' do
      kl_eval('(- 3 2)').should be_kind_of Fixnum
    end

    it ('returns a real when either argument is a real') do
      kl_eval('(- 3.0 2)').should be_kind_of Float
      kl_eval('(- 3 2.0)').should be_kind_of Float
    end

    include_examples 'argument types', %w(- 3 2),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(- 3 2)
    include_examples 'partially-applicable function', %w(- 3 2)
  end

  describe '*' do
    it 'multiplies its arguments' do
      kl_eval('(* 2 3)').should == 6
    end

    it 'returns an integer when both arguments are integers' do
      kl_eval('(* 2 3)').should be_kind_of Fixnum
    end

    it ('returns a real when either argument is a real') do
      kl_eval('(* 2.0 3)').should be_kind_of Float
      kl_eval('(* 2 3.0)').should be_kind_of Float
    end

    include_examples 'argument types', %w(* 2 3),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(* 2 3)
    include_examples 'partially-applicable function', %w(* 2 3)
  end

  describe '/' do
    it 'divides its first argument by its second argument' do
      kl_eval('(/ 6 3)').should == 2
    end

    it 'returns an integer when an integer evenly divides another integer' do
      kl_eval('(/ 6 3)').should be_kind_of Fixnum
    end

    it 'returns a real when an integer does not evenly divide another integer' do
      kl_eval('(/ 4 3)').should be_kind_of Float
    end

    it ('returns a real when either argument is a real') do
      kl_eval('(/ 6.0 3)').should be_kind_of Float
      kl_eval('(/ 6 3.0)').should be_kind_of Float
    end

    include_examples 'argument types', %w(/ 6 3),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(/ 6 3)
    include_examples 'partially-applicable function', %w(/ 6 3)
  end

  describe '>' do
    it 'returns false if its first argument is less than its second argument' do
      kl_eval('(> 1 2)').should == false
    end

    it 'returns false if its first argument is equal to its second argument' do
      kl_eval('(> 2 2)').should == false
    end

    it 'returns true if its first argument is greater than its second argument' do
      kl_eval('(> 3 2)').should == true
    end

    include_examples 'argument types', %w(> 1 2),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(> 1 2)
    include_examples 'partially-applicable function', %w(> 1 2)
  end

  describe '<' do
    it 'returns true if its first argument is less than its second argument' do
      kl_eval('(< 1 2)').should == true
    end

    it 'returns false if its first argument is equal to its second argument' do
      kl_eval('(< 2 2)').should == false
    end

    it 'returns false if its first argument is greater than its second argument' do
      kl_eval('(< 3 2)').should == false
    end

    include_examples 'argument types', %w(< 1 2),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(> 1 2)
    include_examples 'partially-applicable function', %w(> 1 2)
  end

  describe '>=' do
    it 'returns false if its first argument is less than its second argument' do
      kl_eval('(>= 1 2)').should == false
    end

    it 'returns true if its first argument is equal to its second argument' do
      kl_eval('(>= 2 2)').should == true
    end

    it 'returns true if its first argument is greater than its second argument' do
      kl_eval('(>= 3 2)').should == true
    end

    include_examples 'argument types', %w(>= 1 2),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(> 1 2)
    include_examples 'partially-applicable function', %w(> 1 2)
  end

  describe '<=' do
    it 'returns true if its first argument is less than its second argument' do
      kl_eval('(<= 1 2)').should == true
    end

    it 'returns true if its first argument is equal to its second argument' do
      kl_eval('(<= 2 2)').should == true
    end

    it 'returns false if its first argument is greater than its second argument' do
      kl_eval('(<= 3 2)').should == false
    end

    include_examples 'argument types', %w(<= 1 2),
                     1 => [:integer, :real],
                     2 => [:integer, :real]
    include_examples 'applicative order evaluation', %w(> 1 2)
    include_examples 'partially-applicable function', %w(> 1 2)
  end

  describe 'number?' do
    include_examples 'type predicate', 'number?', [:integer, :real]
  end
end
