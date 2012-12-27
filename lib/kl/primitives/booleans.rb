module Kl
  module Primitives
    # The boolean functions are all implemented as short-circuiting special
    # forms in the compiler. The implementations below are for use as
    # arguments to higher-order functions. They are used, e.g., in the
    # Quantifier Machine test case in the Shen Test Suite.
    module Booleans
      define_method 'or', lambda { |a, b|
        a || b
      }.curry

      define_method 'and', lambda { |a, b|
        a && b
      }.curry
    end
  end
end
