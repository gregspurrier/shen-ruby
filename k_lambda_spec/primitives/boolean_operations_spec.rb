require 'spec_helper'

shared_examples "partially-applicable function"  do |args|
  full_expression = "(#{args.join(' ')})"
  (0...(args.length - 1)).each do |arg_count|
    description = "supports partial application of #{arg_count} argument"
    description << "s" unless arg_count == 1
    it description do
      full_result = kl_eval(full_expression)
      partial_expression = "((#{args[0..arg_count].join(' ')}) #{args[(arg_count + 1)..-1].join(' ')})"
      kl_eval(partial_expression).should == full_result
    end
  end
end

describe 'Primitives for Generic Functions' do
  describe 'and special form' do
    it 'evaluates to true if both of its arguments evaluate to true' do
      kl_eval('(and true true)').should == true
    end

    it 'evaluates to false otherwise' do
      kl_eval('(and false true)').should == false
      kl_eval('(and true false)').should == false
      kl_eval('(and false false)').should == false
    end

    it 'does not evaluate its second argument if the first evaluates to false' do
      kl_eval('(set flag clear)')
      kl_eval('(and false (do (set flag set) true))').should == false
      kl_eval('(value flag)').should == :clear
    end

    describe 'partial application' do
      include_examples "partially-applicable function", %w(and true false)

      it 'results in it no longer short-circuiting argument evaluation' do
        kl_eval('(set flag clear)')
        kl_eval('((and false) (do (set flag set) false)))').should == false
        kl_eval('(value flag)').should == :set
      end
    end
  end

  describe 'or special form' do
    it 'evaluates to false if both of its arguments evaluate to false' do
      kl_eval('(or false false)').should == false
    end

    it 'evaluates to true otherwise' do
      kl_eval('(or false true)').should == true
      kl_eval('(or true false)').should == true
      kl_eval('(or true true)').should == true
    end

    it 'does not evaluate its second argument if the first evaluates to true' do
      kl_eval('(set flag clear)')
      kl_eval('(or true (do (set flag set) true))').should == true
      kl_eval('(value flag)').should == :clear
    end

    describe 'partial application' do
      include_examples "partially-applicable function", %w(or true false)

      it 'results in it no longer short-circuiting argument evaluation' do
        kl_eval('(set flag clear)')
        kl_eval('((or true) (do (set flag set) true)))').should == true
        kl_eval('(value flag)').should == :set
      end
    end
  end
end
