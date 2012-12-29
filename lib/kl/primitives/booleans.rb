module Kl
  module Primitives
    # The boolean functions are all implemented as short-circuiting special
    # forms in the compiler. The implementations below are for use as
    # arguments to higher-order functions. They are used, e.g., in the
    # Quantifier Machine test case in the Shen Test Suite.
    module Booleans
      def or(a, b)
        a || b
      end

      def and(a, b)
        a && b
      end
    end
  end
end
