require 'spec_helper'

describe 'Primitives for Generic Functions' do
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
