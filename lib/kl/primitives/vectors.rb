module Kl
  module Primitives
    module Vectors
      def absvector(n)
        Kl::Absvector.new(n)
      end

      define_method "address->" do |v, n, value|
        raise Kl::InternalError, 'nil value' if value.nil?

        if n < 0 || n >= v.upper_limit
          raise Kl::Error, "out of bounds"
        end

        v[n] = value
        v
      end

      define_method "<-address" do |v, n|
        if n < 0 || n >= v.upper_limit
          raise Kl::Error, "out of bounds"
        end

        v[n]
      end

      def absvector?(v)
        v.kind_of? Kl::Absvector
      end
    end
  end
end
