module Kl
  module Primitives
    module Vectors
      def absvector
        Kl::Absvector.new
      end

      define_method "address->" do |vector, n, value|
        vector[n] = value
      end

      define_method "<-address->" do |vector, n|
        vector[n]
      end

      def absvector?(vector)
        vector.kind_of? Kl::Absvector
      end
    end
  end
end
