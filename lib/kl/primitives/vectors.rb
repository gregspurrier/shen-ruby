module Kl
  module Primitives
    module Vectors
      def absvector(n)
        Kl::Absvector.new
      end

      define_method "address->" do |v, n, value|
        v[n] = value
        v
      end

      define_method "<-address" do |v, n|
        v[n]
      end

      def absvector?(v)
        v.kind_of? Kl::Absvector
      end
    end
  end
end
