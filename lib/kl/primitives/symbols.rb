module Kl
  module Primitives
    module Symbols
      def intern(str)
        raise Kl::Error, "#{str} is not a string" unless str.kind_of? String
        # 'true' and 'false' are treated specially and return the
        # corresponding booleans
        if str == 'true'
          true
        elsif str == 'false'
          false
        else
          str.to_sym
        end
      end
    end
  end
end
