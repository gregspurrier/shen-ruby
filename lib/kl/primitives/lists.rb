module Kl
  module Primitives
    module Lists
      def cons(a, b)
        Kl::Cons.new(a, b)
      end

      def hd(a)
        a.hd
      end

      def tl(a)
        a.tl
      end

      def cons?(a)
        a.kind_of? Kl::Cons
      end
    end
  end
end
