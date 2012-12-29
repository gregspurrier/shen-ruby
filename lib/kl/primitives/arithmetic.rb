module Kl
  module Primitives
    module Arithmetic
      def +(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        a + b
      end
      
      def -(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        a - b
      end
      
      def *(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        a * b
      end
      
      def /(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        if a.kind_of?(Fixnum) && b.kind_of?(Fixnum) && a % b != 0
          a = a.to_f
        end
        a / b
      end
      
      def >(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        a > b
      end

      def <(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        a < b
      end
      
      def >=(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        a >= b
      end
      
      def <=(a, b)
        raise ::Kl::Error, "#{a} is not a number" unless a.kind_of? Numeric
        raise ::Kl::Error, "#{b} is not a number" unless b.kind_of? Numeric
        a <= b
      end
      
      def number?(a)
        a.kind_of?(Numeric)
      end
    end
  end
end
