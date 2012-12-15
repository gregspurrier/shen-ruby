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
      define_method "=" do |a, b|
        a == b
      end

      define_method "eval-kl" do |exp|
        __eval(exp)
      end
    end
  end
end
