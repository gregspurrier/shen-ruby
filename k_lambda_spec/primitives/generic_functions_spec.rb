require 'spec_helper'

describe 'Primitives for Generic Functions' do
  describe '(defun Name ArgList Expr)' do
    it 'does not evaulate Expr' do
      kl_eval('(set flag clear)')
      kl_eval('(defun foo () (set flag set))')
      kl_eval('(value flag)').should == :clear
    end

    it 'returns Name' do
      kl_eval('(defun foo () true)').should == :foo
    end

    it 'binds Name to a function having ArgList as its formals and Expr as its body' do
      kl_eval('(defun my-add (A B) (+ A B))')
      kl_eval('(my-add 1 2)').should == 3
    end

    it 'allows ArgList to be the empty list' do
      kl_eval('(defun foo () success)').should == :foo
      kl_eval('(foo)').should == :success
    end

    it 'allows previously defined non-primitive functions to be redefined' do
      kl_eval('(defun my-add (A B) (+ A B))')
      kl_eval('(defun my-add (A B) surprise!)')
      kl_eval('(my-add 1 2)').should == :surprise!
    end

    it 'raises an error when attempting to redefine a primitive' do
      expect {
        kl_eval('(defun + (A B) :surprise!)')
      }.to raise_error(Kl::Error, '+ is primitive and may not be redefined')
    end

    include_examples 'argument types', %w[defun foo () success],
                     1 => [:symbol]

    it 'raises an error if ArgList is not a list' do
      expect {
        kl_eval('(defun foo bar baz)')
      }.to raise_error(Kl::Error, 'bar is not a list')
    end

    it 'raises an error if ArgList contains non-symbols' do
      expect {
        kl_eval('(defun foo (1) baz)')
      }.to raise_error(Kl::Error, '1 is not a symbol')
    end
    include_examples "non-partially-applicable function",
      %w[defun foo () success]
  end

  describe '(lambda X Expr)' do
    it 'does not evaulate Expr' do
      kl_eval('(set flag clear)')
      kl_eval('(lambda X 37)')
      kl_eval('(value flag)').should == :clear
    end

    it 'returns a function' do
      kl_eval('(lambda X 37)').should be_kind_of Proc
    end 

    describe 'the returned function, when applied' do
      it 'evaluates Expr with X bound to its argument' do
        kl_eval('((lambda X (+ 1 X)) 2)').should == 3
      end
    end

    include_examples 'argument types', %w(lambda X 37),
                     1 => [:symbol]
    include_examples "non-partially-applicable function", %w(lambda X 37)
  end

  describe '(freeze Expr)' do
    it 'does not evaluate Expr' do
      kl_eval('(set flag clear)')
      kl_eval('(freeze (set flag set))')
      kl_eval('(value flag)').should == :clear
    end

    it 'returns a continuation' do
      kl_eval('(freeze a)').should be_kind_of Proc
    end

    describe 'the returned continuation, upon thawing' do
      before(:each) do
        kl_eval('(defun my-thaw (X) (X))')
      end

      it 'evaluates and returns the value of Expr' do
        kl_eval('(my-thaw (freeze (+ 1 2)))').should == 3
      end

      it 're-evaluates Expr with each thawing' do
        define_kl_do
        kl_eval('(set count 0)')
        kl_eval('(let C (freeze (set count (+ (value count) 1)))
                      (kl-do (my-thaw C) (my-thaw C)))')
        kl_eval('(value count)').should == 2
      end
    end

    describe 'partial application' do
      # Can't compare two functions so we implement this manually
      it 'supports partial application of 0 arguments' do
        kl_eval('(defun my-thaw (X) (X))')
        kl_eval('(my-thaw ((freeze) 37))').should == 37
      end

      it 'results in it no longer delaying execution of Expr' do
        kl_eval('(set flag clear)')
        kl_eval('((freeze) (set flag set))').should
        kl_eval('(value flag)').should == :set
      end
    end
  end
end
