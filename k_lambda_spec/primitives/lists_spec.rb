require 'spec_helper'

describe 'Primitives for lists' do
  describe '(cons Hd Tl)' do
    it 'creates a list with Hd as the head and Tl as the tail' do
      kl_eval('(cons a ())').should be_kind_of Kl::Cons
      kl_eval('(hd (cons a ()))').should == :a
      kl_eval('(tl (cons a (cons b ())))').should == kl_eval('(cons b ())')
    end

    it 'allows Tl to be a non-list' do
      kl_eval('(tl (cons a b))').should == :b
    end

    include_examples 'partially-applicable function', %w(cons a b)
    include_examples 'applicative order evaluation', %w(cons a b)
  end

  describe '(hd L)' do
    it 'returns the head of L' do
      kl_eval('(hd (cons a b))').should == :a
    end

    include_examples 'argument types', [:hd, "(cons a b)"], 1 => [:list, :dotted_pair]
    include_examples 'partially-applicable function', [:hd, "(cons a b)"]
  end

  describe '(tl L)' do
    it 'returns the tail of L' do
      kl_eval('(tl (cons a b))').should == :b
    end

    include_examples 'argument types', [:tl, "(cons a b)"], 1 => [:list, :dotted_pair]
    include_examples 'partially-applicable function', [:tl, "(cons a b)"]
  end

  describe 'cons?' do
    include_examples 'type predicate', 'cons?', [:list, :dotted_pair]
  end
end
