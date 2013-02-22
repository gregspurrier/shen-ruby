module Kl
  module Primitives
    module Lists
      def cons(a, b)
        Kl::Cons.new(a, b)
      end

      def hd(a)
        raise Kl::Error, "#{a} is not a list" unless a.kind_of? Kl::Cons
        a.hd
      end

      def tl(a)
        raise Kl::Error, "#{a} is not a list" unless a.kind_of? Kl::Cons
        a.tl
      end

      def cons?(a)
        a.kind_of? Kl::Cons
      end
    end
  end
end
