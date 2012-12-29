module Kl
  module Primitives
    # For the time being, Shen Ruby's string functions only support 8-bit 
    # characters. Once the Shen environment is up and running and passing
    # its test suite, strings will be extended to support UTF-8.
    module Strings
      def pos(s, n)
        s.byteslice(n)
      end
      
      def tlstr(s)
        if s.empty?
          :"shen-eos"
        else
          s.byteslice(1, s.bytesize - 1)
        end
      end
      
      def cn(s1, s2)
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
        "" << n
      end

      define_method 'string->n' do |s|
        s.bytes.to_a.first
      end
    end
  end
end
