module Kl
  module Primitives
    module Time
      define_method 'get-time' do |time_type|
        case time_type
        when :run, :real
          ::Time.now.to_f
        when :unix
          ::Time.now.to_i
        else
          raise Kl::Error, "unsupported time type: #{time_type}"
        end
      end
    end
  end
end
  
