require 'spec_helper'

describe 'Atoms:' do
  describe 'a string' do
    it 'is self-evaluating' do
      kl_eval('"string"').should == 'string'
    end
  end

  describe 'a symbol' do
    it 'is self-evaluating' do
      kl_eval('symbol').should == :symbol
    end

    it 'may include any of the legal characters for symbol' do
      # See http://www.shenlanguage.org/documentation/shendoc.htm#The%20Syntax%20of%20Symbols
      all_legal_chars = 'abcdefghijklmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
          '0123456789' +
          '=-*/+_?$!@~.><&%\'#`;:{}'
      kl_eval(all_legal_chars).should == all_legal_chars.to_sym
    end

    it 'may begin with any legal character other than a digit' do
      legal_non_digits = 'abcdefghijklmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
          '=-*/+_?$!@~.><&%\'#`;:{}'
      legal_non_digits.each_char do |char|
        kl_eval(char).should == char.to_sym
      end
    end

    it 'may not begin with a digit' do
      digits = '01234567890'
      digits.each_char do |char|
        kl_eval(char).should_not be_kind_of Symbol
      end
    end
  end

  describe 'numbers' do
    it 'parses integers as integers' do
      result = kl_eval('123')
      result.should == 123
      result.should be_kind_of Fixnum
    end

    it 'parses floating point numbers as reals' do
      result = kl_eval('12.3')
      result.should == 12.3
      result.should be_kind_of Float
    end

    describe 'with leading sign characters' do
      it 'recognizes negative numbers' do
        kl_eval('-123').should == -123
      end

      it 'treats any odd number of minuses as negative' do
        kl_eval('---123').should == -123
      end

      it 'treats any even number of minuses as positive' do
        kl_eval('----123').should == 123
      end

      it 'ignores leading plusses' do
        kl_eval('+123').should == 123
        kl_eval('--+-123').should == -123
      end
    end
  end

  describe 'true' do
    it 'evaluates to boolean true rather than a symbol' do
      kl_eval('true').should == true
    end
  end

  describe 'false' do
    it 'evaluates to boolean false rather than a symbol' do
      kl_eval('false').should == false
    end
  end
end
