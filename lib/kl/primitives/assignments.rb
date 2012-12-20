module Kl
  module Primitives
    module Assignments
      def set(sym, value)
        @variables[sym] = value
        value
      end

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
