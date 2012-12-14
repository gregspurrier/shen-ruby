module Kl
  module Primitives
    module Symbols
      def intern(str)
        str.to_sym
      end
    end
  end
end
