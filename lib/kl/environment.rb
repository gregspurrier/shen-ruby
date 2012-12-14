require 'kl/compiler'
require 'kl/primitives/error_handling'
require 'kl/primitives/arithmetic'

module Kl
  class Environment
    include ::Kl::Primitives::ErrorHandling
    include ::Kl::Primitives::Arithmetic

    # Associate proc p with the specified name in the function namespace
    def __defun(name, p)
      eigenklass = class << self; self; end
      eigenklass.send(:define_method, name, p)
    end

    def __function(obj)
      p = case obj
          when Proc
            obj
          when Symbol
            method(obj).to_proc
          else
            raise "function applied to #{obj.class}"
          end
      p.curry
    end

    def __eval(form)
      code = ::Kl::Compiler.compile(form)
      instance_eval(code)
    end
  end
end
