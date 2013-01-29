require 'spec_helper'

describe 'Primitives for assignment' do
  describe '(set Name Value)' do
    it 'associates Value with Name' do
      kl_eval('(set foo bar)')
      kl_eval('(value foo)').should == :bar
    end

    it 'returns Value' do
      kl_eval('(set foo bar)').should == :bar
    end

    it 'overwrites the previous value when called again with same Name' do
      kl_eval('(set foo bar)')
      kl_eval('(set foo baz)').should == :baz
    end

    include_examples 'argument types', %w(set foo bar), 1 => [:symbol]
    include_examples 'partially-applicable function', %w(set foo bar)
    include_examples 'applicative order evaluation', %w(set foo bar)
  end

  describe '(value Name)' do
    before(:each) do
      # a-symbol is the example symbol used by the argument type specs.
      # Set it so that they do not throw and unset variable error.
      kl_eval('(set a-symbol bar)')
    end

    it 'returns the value associated with Name' do
      kl_eval('(value a-symbol)').should == :bar
    end

    it 'raises an error if Name has not previously been set' do
      expect {
        kl_eval('(value baz)')
      }.to raise_error(Kl::Error, 'variable baz has no value')
    end

    include_examples 'argument types', %w(value a-symbol), 1 => [:symbol]
    include_examples 'partially-applicable function', %w(value a-symbol)
  end
end
