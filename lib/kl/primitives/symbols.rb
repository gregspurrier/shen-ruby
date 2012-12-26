module Kl
  module Primitives
    module Symbols
      define_method 'intern', lambda { |str|
        # 'true' and 'false' are treated specially and return the
        # corresponding booleans
        if str == 'true'
          true
        elsif str == 'false'
          false
        else
          str.to_sym
        end
      }.curry
    end
  end
end
