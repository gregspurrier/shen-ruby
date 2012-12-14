require 'kl/compiler'

module Kl
  class Environment < BasicObject
    def __eval(form)
      code = ::Kl::Compiler.compile(form)
      instance_eval(code)
    end
  end
end
