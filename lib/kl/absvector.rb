module Kl
  # Absvectors are just arrays. We give them their own subclass
  # to support the absvector? primitive.
  class Absvector < Array
    attr_reader :upper_limit

    def initialize(n)
      super(n, :"shen.fail!")
      @upper_limit = n
    end
  end
end
