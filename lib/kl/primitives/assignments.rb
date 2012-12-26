module Kl
  module Primitives
    module Assignments
      # Curried after inclusion
      def set(sym, value)
        @variables[sym] = value
        value
      end

      # Curried after inclusion
      def value(sym)
        if @variables.has_key?(sym)
          @variables[sym]
        else
          raise Kl::Error, "variable #{sym} has no value"
        end
      end
    end
  end
end
