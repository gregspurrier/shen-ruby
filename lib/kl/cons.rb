require 'kl/empty_list'

module Kl
  class Cons
    include Enumerable

    attr_reader :hd, :tl

    def initialize(hd, tl)
      @hd = hd
      @tl = tl
    end

    def ==(other)
      other.kind_of?(Kl::Cons) && hd == other.hd && tl == other.tl
    end

    def each
      cell = self
      while !cell.kind_of? Kl::EmptyList
        yield cell.hd
        cell = cell.tl
      end
    end

    class << self
      def list(array)
        if array.empty?
          Kl::EmptyList.instance
        else
          index = array.size - 1
          head = new(array[index], Kl::EmptyList.instance)
          index = index - 1
          while index >= 0
            head = new(array[index], head)
            index = index - 1
          end
          head
        end
      end
    end
  end
end
