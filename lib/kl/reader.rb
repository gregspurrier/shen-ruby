require 'kl/lexer'

module Kl
  class Reader
    def initialize(stream)
      @lexer = Kl::Lexer.new(stream)
    end

    def next
      token = @lexer.next
      unless token.nil? 
        if token.kind_of? Kl::Lexer::OpenParen
          read_list
        else
          token
        end
      end
    end

  private

    def read_list
      items = []

      loop do
        token = @lexer.next
        raise Kl::Error, 'Unterminated list' if token.nil?
        case token
        when Kl::Lexer::OpenParen
          items << read_list
        when Kl::Lexer::CloseParen
          break
        else
          items << token
        end
      end
      Kl::Cons.list(items)
    end
  end
end
