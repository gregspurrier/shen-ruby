module Kl
  module Primitives
    module Vectors
      define_method 'absvector', lambda { |n|
        Kl::Absvector.new(n)
      }.curry

      define_method 'address->', lambda { |v, n, value|
        if n < 0 || n >= v.upper_limit
          raise Kl::Error, "out of bounds"
        end

        v[n] = value
        v
      }.curry

      define_method '<-address', lambda { |v, n|
        if n < 0 || n >= v.upper_limit
          raise Kl::Error, "out of bounds"
        end

        v[n]
      }.curry

      define_method 'absvector?', lambda { |v|
        v.kind_of? Kl::Absvector
      }.curry
    end
  end
end
