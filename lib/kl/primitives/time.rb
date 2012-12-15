module Kl
  module Primitives
    module Time
      define_method "get-time" do |time_type|
        case time-type
        when :real, :unix
          ::Time.now.to_i
        else
          raise Kl::Error, "unsupported time type: #{time_type}"
        end
      end
    end
  end
end
  
