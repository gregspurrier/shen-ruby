module ShenRuby
  module Converters
    include Klam::Converters::List

    def array_to_list(a)
      arrayToList(a)
    end

    def list_to_array(l)
      listToArray(l)
    end

    def array_to_vector(a)
      v = Klam::Absvector.new(a)
      v.unshift(a.size)
      v
    end

    def vector_to_array(v)
      Array.new(v.slice(1,v[0]))
    end
  end
end
