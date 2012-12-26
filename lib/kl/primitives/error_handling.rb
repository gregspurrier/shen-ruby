module Kl
  module Primitives
    module ErrorHandling
      define_method "simple-error" do |err_msg|
        raise Kl::Error, err_msg
      end

      define_method "error-to-string" do |err|
        err.message
      end
    end
  end
end
