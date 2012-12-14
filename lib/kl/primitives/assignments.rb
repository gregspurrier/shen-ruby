module Kl
  module Primitives
    module Assignments
      def set(sym, value)
        @variables[sym] = value
        value
      end

      def value(sym)
        @variables[sym]
      end
    end
  end
end
