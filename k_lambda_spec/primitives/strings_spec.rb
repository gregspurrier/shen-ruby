require 'spec_helper'

describe 'Primitives for strings' do
  describe '(pos S N)' do
    it 'returns the character at zero-based index N of S as a unit string' do
      kl_eval('(pos "ABC" 1)').should == "B"
    end

    it 'raises an error if N is negative' do
      expect {
        kl_eval('(pos "ABC" -1)')
      }.to raise_error(Kl::Error, "out of bounds")
    end

    it 'raises an error if N is >= the length of S' do
      expect {
        kl_eval('(pos "ABC" 3)')
      }.to raise_error(Kl::Error, "out of bounds")
      expect {
        kl_eval('(pos "ABC" 99)')
      }.to raise_error(Kl::Error, "out of bounds")
    end

    include_examples 'argument types', %w(pos "string" 1),
                     1 => [:string],
                     2 => [:integer]
    include_examples 'partially-applicable function', %w(pos "string" 1)
    include_examples 'applicative order evaluation', %w(pos "string" 1)
  end

  describe '(tlstr S)' do
    it 'returns a string containing all but the first character of S' do
      kl_eval('(tlstr "string")').should == "tring"
    end

    it 'raises an error when S is the empty string' do
      expect {
        kl_eval('(tlstr "")')
      }.to raise_error(Kl::Error, 'attempted to take tail of an empty string')
    end

    include_examples 'argument types', %w(tlstr "string"), 1 => [:string]
    include_examples 'partially-applicable function', %w(tlstr "string")
  end

  describe 'string?' do
    include_examples 'type predicate', 'string?', [:string]
  end

  describe '(n->string N)' do
    it 'returns a unit string containing the character with ASCII code N' do
      kl_eval('(n->string 65)').should == "A"
    end

    include_examples 'argument types', %w(n->string 65), 1 => [:integer]
    include_examples 'partially-applicable function', %w(n->string 65)
  end

  describe '(string->n S)' do
    it 'returns the ASCII code of the unit string S' do
      kl_eval('(string->n "A")').should == 65
    end

    it 'returns the ASCII code of the first character of non-unit string S' do
      kl_eval('(string->n "AB")').should == 65
    end

    it 'raises an error when S is the empty string' do
      expect {
        kl_eval('(string->n "")')
      }.to raise_error(Kl::Error, 'attempted to get code point of empty string')
    end

    include_examples 'argument types', %w(string->n "A"), 1 => [:string]
    include_examples 'partially-applicable function', %w(string->n "A")
  end
end
