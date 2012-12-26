module Kl
  module Primitives
    module Time
      define_method 'get-time', lambda { |time_type|
        case time_type
        when :run, :real, :unix
          ::Time.now.to_i
        else
          raise Kl::Error, "unsupported time type: #{time_type}"
        end
      }.curry
    end
  end
end
  
