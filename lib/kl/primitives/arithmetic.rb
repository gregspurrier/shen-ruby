module Kl
  module Primitives
    module Arithmetic
      def +(a, b)
        a + b
      end
      
      def -(a, b)
        a - b
      end
      
      def *(a, b)
        a * b
      end
      
      def /(a, b)
        if a.kind_of?(Fixnum) && b.kind_of?(Fixnum) && a % b != 0
          a = a.to_f
        end
        a / b
      end
      
      def >(a, b)
        a > b
      end

      def <(a, b)
        a < b
      end
      
      def >=(a, b)
        a >= b
      end
      
      def <=(a, b)
        a <= b
      end
      
      def number?(a)
        a.kind_of?(Numeric)
      end
    end
  end
end
