module Kl
  module Primitives
    module Lists
      def cons(a, b)
        raise Kl::InternalError, "hd is nil" if a.nil?
        raise Kl::InternalError, "hd is nil" if b.nil?
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
