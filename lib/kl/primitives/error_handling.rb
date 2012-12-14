module Kl
  module Primitives
    module ErrorHandling
      define_method "simple-error" do |err_msg|
        raise Kl::Error, err_msg
      end

      define_method "error-to-string" do |err|
        "Error: #{err.message}\n" +
          "Stack:\n  " +
          (err.backtrace || []).join("\n  ") +
          "\n"
      end
    end
  end
end
