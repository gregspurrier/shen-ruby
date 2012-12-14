require 'singleton'

module Kl
  class EmptyList
    include Singleton
    include Enumerable

    def each
      # no-op
    end
  end
end
