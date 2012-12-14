require 'kl/compiler'
require 'kl/primitives/arithmetic'

module Kl
  class Environment
    include ::Kl::Primitives::Arithmetic

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
