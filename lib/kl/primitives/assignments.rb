module Kl
  module Primitives
    module Assignments
      def set(sym, value)
        raise Kl::Error, "#{sym} is not a symbol" unless sym.kind_of? Symbol
        @variables[sym] = value
        value
      end

      def value(sym)
        @variables[sym]
      end
    end
  end
end
