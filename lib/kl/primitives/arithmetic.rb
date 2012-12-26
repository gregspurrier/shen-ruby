module Kl
  module Primitives
    module Arithmetic
      define_method '+', lambda { |a, b|
        a + b
      }.curry
      
      define_method '-', lambda { |a, b|
        a - b
      }.curry
      
      define_method '*', lambda { |a, b|
        a * b
      }.curry
      
      define_method '/', lambda { |a, b|
        if a.kind_of?(Fixnum) && b.kind_of?(Fixnum) && a % b != 0
          a = a.to_f
        end
        a / b
      }
      
      define_method '>', lambda { |a, b|
        a > b
      }.curry

      define_method '<', lambda { |a, b|
        a < b
      }.curry
      
      define_method '>=', lambda { |a, b|
        a >= b
      }.curry
      
      define_method '<=', lambda { |a, b|
        a <= b
      }.curry
      
      define_method 'number?', lambda { |a|
        a.kind_of?(Numeric)
      }.curry
    end
  end
end
