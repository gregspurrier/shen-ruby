require 'spec_helper'
require 'stringio'

describe Kl::Lexer do
  def lexer(str)
    Kl::Lexer.new(StringIO.new(str))
  end

  describe 'syntax tokens' do
    it 'reads ( as a Kl::Lexer::OpenParen' do
      lexer("(").next.should be_kind_of Kl::Lexer::OpenParen
    end

    it 'reads ) as a Kl::Lexer::CloseParen' do
      lexer(")").next.should be_kind_of Kl::Lexer::CloseParen
    end
  end

  describe 'string tokens' do
    it 'reads double-quoted strings' do
      lexer('"Fred"').next.should == "Fred"
    end

    it 'throws Kl::Lexer::Error on unterminated strings' do
      expect {
        lexer('"Fred').next
      }.to raise_error(Kl::Lexer::Error, "unterminated string")
    end
  end

  describe 'symbols' do
    it 'reads sign characters not followed by digits as symbols' do
      lexer('-').next.should == '-'.to_sym
      lexer('+').next.should == '+'.to_sym
      lexer('--+-').next.should == '--+-'.to_sym
    end

    it 'reads double decimal points followed by digits as symbols' do
      lexer('..77').next.should == '..77'.to_sym
    end

    it "accepts =-*/+_?$!@~><&%'#`;:{} in symbols" do
      all_punctuation = "=-*/+_?$!@~><&%'#`;:{}"
      sym = lexer(all_punctuation).next
      sym.should be_kind_of Symbol
      sym.to_s.should == all_punctuation
    end
  end

  describe 'numbers' do
    it 'reads integers as Fixnums' do
      num = lexer("37").next
      num.should be_kind_of Fixnum
      num.should == 37
    end
    
    it 'reads floating points as Floats' do
      num = lexer("37.42").next
      num.should be_kind_of Float
      num.should == 37.42
    end

    it 'with an odd number of leading minuses are negative' do
      lexer('-1').next.should == -1
      lexer('---1').next.should == -1
    end

    it 'with an even number of leading minuses are positive' do
      lexer('--1').next.should == 1
      lexer('----1').next.should == 1
    end

    it 'with leading + does not change sign' do
      lexer('+-1').next.should == -1
      lexer('-+--1').next.should == -1
      lexer('-+-+1').next.should == 1
      lexer('+-+-+-+-+1').next.should == 1
    end

    it 'allows leading decimal points' do
      lexer('.9').next.should == 0.9
      lexer('-.9').next.should == -0.9
    end

    it 'treats a trailing decimal followed by EOF as a symbol' do
      l = lexer('7.')
      num = l.next
      num.should be_kind_of Fixnum
      num.should == 7

      sym = l.next
      sym.should be_kind_of Symbol
      sym.to_s.should == '.'
    end

    it 'treats a trailing decimal followed by non-digit as a symbol' do
      l = lexer('7.a')
      num = l.next
      num.should be_kind_of Fixnum
      num.should == 7

      sym = l.next
      sym.should be_kind_of Symbol
      sym.to_s.should == '.a'
    end

    it 'handles multiple decimal points like shen does' do
      l = lexer('7.8.9')
      l.next.should == 7.8
      l.next.should == 0.9
    end
  end

  describe 'booleans' do
    it 'reads true as boolean true' do
      lexer('true').next.should be_kind_of TrueClass
    end

    it 'reads false as boolean false' do
      lexer('false').next.should be_kind_of FalseClass
    end
  end

  describe 'whitespace' do
    it 'is ignored between tokens' do
      l = lexer("     (\n\t)   ")
      l.next.should be_kind_of Kl::Lexer::OpenParen
      l.next.should be_kind_of Kl::Lexer::CloseParen
      l.next.should be_nil
    end

    it 'is left intact in strings' do
      lexer('     "one two"   ').next.should == "one two"
    end
  end

  it 'works with these all together' do
    l = lexer('(12 quick m-*$ RAN `fast\' -.7) "oh 12 yeah!"  ')
    l.next.should be_kind_of Kl::Lexer::OpenParen
    l.next.should == 12
    l.next.should == :quick
    l.next.should == 'm-*$'.to_sym
    l.next.should == :RAN
    l.next.should == "`fast'".to_sym
    l.next.should == -0.7
    l.next.should be_kind_of Kl::Lexer::CloseParen
    l.next.should == "oh 12 yeah!"
    l.next.should be_nil
  end
end
