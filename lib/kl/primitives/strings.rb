module Kl
  module Primitives
    # For the time being, Shen Ruby's string functions only support 8-bit 
    # characters. Once the Shen environment is up and running and passing
    # its test suite, strings will be extended to support UTF-8.
    module Strings
      def pos(s, n)
        raise Kl::Error, "#{s} is not a string" unless s.kind_of? String
        raise Kl::Error, "#{n} is not an integer" unless n.kind_of? Fixnum
        if n < 0 || n >= s.length
          raise Kl::Error, "out of bounds"
        end
        s.byteslice(n)
      end
      
      def tlstr(s)
        raise Kl::Error, "#{s} is not a string" unless s.kind_of? String
        raise Kl::Error, "attempted to take tail of an empty string" if s.empty?
        s.byteslice(1, s.bytesize - 1)
      end
      
      def cn(s1, s2)
        raise Kl::Error, "#{s1} is not a string" unless s1.kind_of? String
        raise Kl::Error, "#{s2} is not a string" unless s2.kind_of? String
        s1 + s2
      end
      
      def str(x)
        case x
        when String
          '"' + x + '"'
        when Symbol
          x.to_s
        when Numeric
          x.to_s
        when TrueClass, FalseClass
          x.to_s
        when Proc
          x.to_s
        when IO
          x.to_s
        else
          raise Kl::Error, "str applied to non-atomic type: #{x.class}"
        end
      end
      
      def string?(x)
        x.kind_of? String
      end

      define_method 'n->string' do |n|
        raise Kl::Error, "#{n} is not an integer" unless n.kind_of? Fixnum
        "" << n
      end

      define_method 'string->n' do |s|
        raise Kl::Error, "#{s} is not a string" unless s.kind_of? String
        raise Kl::Error, 'attempted to get code point of empty string' if s.empty?
        s.bytes.to_a.first
      end
    end
  end
end
