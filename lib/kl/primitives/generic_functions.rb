module Kl
  module Primitives
    # The following functions are implemented as special forms
    # in Kl::Compiler:
    #
    #  - defun
    #  - lambda
    #  - let
    #  - freeze
    #  - type
    module GenericFunctions
      define_method '=' do |a, b|
        a == b
      end

      # Curried after inclusion
      define_method 'eval-kl' do |exp|
        __eval(exp)
      end

      # Freeze is also provided as a normal function to support
      # the partial application of zero arguments case. In this
      # case it becomes a non-special-form.
      def freeze(exp)
        Kernel.lambda { exp }
      end
    end
  end
end
