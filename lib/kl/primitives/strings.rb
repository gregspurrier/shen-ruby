module Kl
  module Primitives
    # For the time being, Shen Ruby's string functions only support 8-bit 
    # characters. Once the Shen environment is up and running and passing
    # its test suite, strings will be extended to support UTF-8.
    module Strings
      define_method 'pos', lambda { |s, n|
        s.byteslice(n)
      }.curry
      
      define_method 'tlstr', lambda { |s|
        if s.empty?
          :"shen-eos"
        else
          s.byteslice(1, s.bytesize - 1)
        end
      }.curry
      
      define_method 'cn', lambda { |s1, s2|
        s1 + s2
      }.curry
      
      define_method 'str', lambda { |x|
        case x
        when String
          '"' + x + '"'
        when Symbol
          x.to_s
        when Numeric
          x.to_s
        when TrueClass, FalseClass
          x.to_s
        when Proc
          x.to_s
        when IO
          x.to_s
        else
          raise Kl::Error, "str applied to non-atomic type: #{x.class}"
        end
      }.curry
      
      define_method 'string?', lambda { |x|
        x.kind_of? String
      }.curry

      define_method 'n->string', lambda { |n|
        "" << n
      }.curry

      define_method 'string->n', lambda { |s|
        s.bytes.to_a.first
      }.curry
    end
  end
end
