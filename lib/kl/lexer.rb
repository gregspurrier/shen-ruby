require 'singleton'

module Kl
  class Lexer
    class Error < StandardError
    end

    SYMBOL_CHARS = /[-=*\/+_?$!\@~><&%'#`;:{}a-zA-Z0-9.]/

    # Syntax tokens
    class OpenParen
      include Singleton
    end
    class CloseParen
      include Singleton
    end

    def initialize(stream)
      @stream = stream
    end

    def next
      drain_whitespace
      unless @stream.eof?
        c = @stream.getc
        case c
        when '('
          OpenParen.instance
        when ')'
          CloseParen.instance
        when '"'
          consume_string
        when SYMBOL_CHARS
          @stream.ungetc(c)
          consume_number_or_symbol
        else
          raise Error, "illegal character: #{c}"
        end
      end
    end

  private
    def drain_whitespace
      until @stream.eof?
        c = @stream.getc
        if c =~ /\S/
          @stream.ungetc(c)
          break
        end
      end
    end

    def consume_string
      chars = []
      loop do
        raise Error, "unterminated string" if @stream.eof?
        c = @stream.getc
        break if c == '"'
        chars << c
      end
      chars.join
    end

    def consume_number
      # Shen allows multiple leading plusses and minuses. The plusses
      # are ignored and an even number of minuses cancel each other.
      # Thus '------+-7' is read as 7. 
      #
      # The Shen reader parses "7." as the integer 7 and the symbol '.'
      decimal_seen = false
      negative = false
      past_sign = false
      chars = []
      loop do
        break if @stream.eof?
        c = @stream.getc
        if c =~ /\d/
          past_sign = true
          chars << c
        elsif c == '.' && !decimal_seen
          past_sign = true
          decimal_seen = true
          chars << c
        elsif c == '+' && !past_sign
          # ignore
        elsif c == '-' && !past_sign
          negative = !negative
        else
          @stream.ungetc c
          break
        end
      end
      chars.unshift('-') if negative
      if chars.last == '.'
        # A trailing decimal point is treated as part of the next
        # token. Forget we saw it.
        @stream.ungetc(chars.pop)
        decimal_seen = false
      end
      str = chars.join
      decimal_seen ? str.to_f : str.to_i
    end

    def consume_symbol
      chars = []
      loop do
        break if @stream.eof?
        c = @stream.getc
        unless c =~ SYMBOL_CHARS
          @stream.ungetc c
          break
        end
        chars << c
      end
      str = chars.join

      case str
      when 'true'
        true
      when 'false'
        false
      else
        str.to_sym
      end
    end

    def consume_number_or_symbol
      # First drain optional leading signs
      # Then drain optional decimal point
      # If there is another character and it is a digit, then it
      # is a number. Otherwise it is a symbol.
      chars = []
      loop do
        break if @stream.eof?
        c = @stream.getc
        unless c =~ /[-+]/
          @stream.ungetc c
          break
        end
        chars << c
      end
      if @stream.eof?
        chars.reverse.each {|c| @stream.ungetc c}
        return consume_symbol
      end

      c = @stream.getc
      chars << c
      if c == '.'
        if @stream.eof?
          chars.reverse.each {|c| @stream.ungetc c}
          return consume_symbol
        end
        c = @stream.getc
        chars << c
        chars.reverse.each {|c| @stream.ungetc c}
        if c =~ /\d/
          return consume_number
        else
          return consume_symbol
        end          
      elsif c =~ /\d/
        chars.reverse.each {|c| @stream.ungetc c}
        return consume_number
      else
        chars.reverse.each {|c| @stream.ungetc c}
        return consume_symbol
      end
    end
  end
end
