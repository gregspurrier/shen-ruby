module Kl
  module Primitives
    # Extensions to the official set of K Lambda primitives.
    # Unlike the official primitives, these are allowed to be overridden
    # by the Shen sources later.
    module Extensions
      define_method 'do' do |a, b|
        b
      end
    end
  end
end
