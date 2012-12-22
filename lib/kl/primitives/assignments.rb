module Kl
  module Primitives
    module Assignments
      def set(sym, value)
        raise Kl::InternalError, "sym is nil" if sym.nil?
        raise Kl::InternalError, "value is nil" if value.nil?
        @variables[sym] = value
        value
      end

      def value(sym)
        raise Kl::InternalError, "sym is nil" if sym.nil?
        if @variables.has_key?(sym)
          @variables[sym]
        else
          raise Kl::Error, "variable #{sym} has no value"
        end
      end
    end
  end
end
