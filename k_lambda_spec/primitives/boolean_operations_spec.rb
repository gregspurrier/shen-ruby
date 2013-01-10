require 'spec_helper'

describe 'Primitives for Boolean Operations' do
  describe 'if special form' do
    include_examples "non-partially-applicable function", %w(if true a b)

    it 'evaluates its first argument' do
      define_kl_do
      kl_eval('(set flag clear)')
      kl_eval('(if (kl-do (set flag set) true) a b)')
      kl_eval('(value flag)').should == :set
    end

    describe 'when its first argument evaluates to true' do
      it 'returns the normal form of its second argument' do
        kl_eval('(if true (+ 1 2) 10)').should == 3
      end

      it 'does not evaluate its third argument' do
        define_kl_do
        kl_eval('(set flag clear)')
        kl_eval('(if true 1 (kl-do (set flag set) 2))')
        kl_eval('(value flag)').should == :clear
      end
    end

    describe 'when its first argument evaluates to false' do
      it 'returns the normal form of its third argument' do
        kl_eval('(if false 1 (+ 1 2))').should == 3
      end

      it 'does not evaluate its second argument' do
        define_kl_do
        kl_eval('(set flag clear)')
        kl_eval('(if false (kl-do (set flag set) 1) 2)')
        kl_eval('(value flag)').should == :clear
      end
    end
  end

  describe 'and special form' do
    it 'evaluates its first argument' do
      define_kl_do
      kl_eval('(set flag clear)')
      kl_eval('(and (kl-do (set flag set) true) false)')
      kl_eval('(value flag)').should == :set
    end

    describe 'when its first argument evaluates to true' do
      it 'returns true if its second argument evaluates to true' do
        kl_eval('(defun return-true () true)')
        kl_eval('(and true (return-true))').should == true
      end

      it 'returns false if its second argument evaluates to false' do
        kl_eval('(defun return-false () false)')
        kl_eval('(and true (return-false))').should == false
      end
    end

    describe 'when its first argument evaluates to false' do
      it 'returns false' do
        kl_eval('(and false true)').should == false
      end

      it 'does not evaluate it second argument' do
        kl_eval('(set flag clear)')
        kl_eval('(and false (kl-do (set flag set) true))').should == false
        kl_eval('(value flag)').should == :clear
      end
    end

    describe 'partial application' do
      include_examples "partially-applicable function", %w(and true false)

      it 'results in it no longer short-circuiting argument evaluation' do
        define_kl_do
        kl_eval('(set flag clear)')
        kl_eval('((and false) (kl-do (set flag set) false)))').should == false
        kl_eval('(value flag)').should == :set
      end
    end

    it 'may be passed as an argument to a higher-order function' do
      kl_eval('((lambda F (F true false)) and)').should == false
    end
  end

  describe 'or special form' do
    it 'evaluates its first argument' do
      define_kl_do
      kl_eval('(set flag clear)')
      kl_eval('(or (kl-do (set flag set) false) false)')
      kl_eval('(value flag)').should == :set
    end

    describe 'when its first argument evaluates to false' do
      it 'returns true if its second argument evaluates to true' do
        kl_eval('(defun return-true () true)')
        kl_eval('(or false (return-true))').should == true
      end

      it 'returns false if its second argument evaluates to false' do
        kl_eval('(defun return-false () false)')
        kl_eval('(or false (return-false))').should == false
      end
    end

    describe 'when its first argument evaluates to true' do
      it 'returns true' do
        kl_eval('(or true false)').should == true
      end

      it 'does not evaluate it second argument' do
        kl_eval('(set flag clear)')
        kl_eval('(or true (kl-do (set flag set) false))').should == true
        kl_eval('(value flag)').should == :clear
      end
    end

    describe 'partial application' do
      include_examples "partially-applicable function", %w(or false true)

      it 'results in it no longer short-circuiting argument evaluation' do
        define_kl_do
        kl_eval('(set flag clear)')
        kl_eval('((or true) (kl-do (set flag set) false)))').should == true
        kl_eval('(value flag)').should == :set
      end
    end

    it 'may be passed as an argument to a higher-order function' do
      kl_eval('((lambda F (F true true)) or)').should == true
    end
  end
end
