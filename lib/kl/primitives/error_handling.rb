module Kl
  module Primitives
    module ErrorHandling
      define_method "simple-error", lambda { |err_msg|
        raise Kl::Error, err_msg
      }.curry

      define_method "error-to-string", lambda { |err|
        err.message
      }.curry
    end
  end
end
