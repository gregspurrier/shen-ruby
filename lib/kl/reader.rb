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
      stack = [items]

      until stack.empty? do
        token = @lexer.next
        raise Kl::Error, 'Unterminated list' if token.nil?
        case token
        when Kl::Lexer::OpenParen
          items = []
          stack.push items
        when Kl::Lexer::CloseParen
          list = Kl::Cons.list(stack.pop)
          unless stack.empty?
            items = stack.last
            items << list
          end
        else
          items << token
        end
      end
      list
    end
  end
end
