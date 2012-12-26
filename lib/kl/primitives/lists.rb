module Kl
  module Primitives
    module Lists
      define_method 'cons', lambda { |a, b|
        Kl::Cons.new(a, b)
      }.curry

      define_method 'hd', lambda { |a|
        a.hd
      }.curry

      define_method 'tl', lambda { |a|
        a.tl
      }.curry

      define_method 'cons?', lambda { |a|
        a.kind_of? Kl::Cons
      }.curry
    end
  end
end
