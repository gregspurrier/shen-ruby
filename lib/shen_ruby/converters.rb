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
      Klam::Absvector.new(a)
    end

    def vector_to_array(v)
      v.to_a
    end
  end
end
