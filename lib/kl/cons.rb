require 'kl/empty_list'

module Kl
  class Cons
    attr_reader :hd, :tl

    def initialize(hd, tl)
      @hd = hd
      @tl = tl
    end

    def ==(other)
      hd == other.hd && tl == other.tl
    end

    class << self
      def list(array)
        if array.empty?
          Kl::EmptyList.instance
        else
          new(array[0], list(array[1..-1]))
        end
      end
    end
  end
end
