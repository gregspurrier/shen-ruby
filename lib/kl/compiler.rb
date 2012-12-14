module Kl
  module Compiler
    class << self
      def compile(form)
        case form
        when Symbol
          ':"' + form.to_s + '"'
        when String
          # Emit non-interpolating strings
          "'" + escape_string(form) + "'"
        when Numeric
          form.to_s
        when true
          'true'
        when false
          'false'
        end
      end

    private

      # Escape single quotes and backslashes
      def escape_string(str)
        new_str = ""
        str.each_char do |c|
          if c == "'"
            new_str << "\\"
            new_str << "'"
          elsif c == '\\'
            new_str << '\\'
            new_str << '\\'
          else
            new_str << c
          end
        end
        new_str
      end
    end
  end
end
