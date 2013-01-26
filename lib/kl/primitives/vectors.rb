module Kl
  module Primitives
    module Vectors
      def absvector(n)
        raise Kl::Error, "#{n} is not a number" unless n.kind_of? Fixnum
        Kl::Absvector.new(n)
      end

      define_method 'address->' do |v, n, value|
        raise Kl::Error, "#{v} is not a vector" unless v.kind_of? Kl::Absvector
        raise Kl::Error, "#{n} is not a number" unless n.kind_of? Fixnum
        if n < 0 || n >= v.upper_limit
          raise Kl::Error, "out of bounds"
        end

        v[n] = value
        v
      end

      define_method '<-address' do |v, n|
        raise Kl::Error, "#{v} is not a vector" unless v.kind_of? Kl::Absvector
        raise Kl::Error, "#{n} is not a number" unless n.kind_of? Fixnum
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
