require 'kl/compiler'
require 'kl/primitives/symbols'
require 'kl/primitives/strings'
require 'kl/primitives/assignments'
require 'kl/primitives/error_handling'
require 'kl/primitives/lists'
require 'kl/primitives/generic_functions'
require 'kl/primitives/vectors'
require 'kl/primitives/streams'
require 'kl/primitives/time'
require 'kl/primitives/arithmetic'

module Kl
  class Environment
    include ::Kl::Primitives::Symbols
    include ::Kl::Primitives::Strings
    include ::Kl::Primitives::Assignments
    include ::Kl::Primitives::ErrorHandling
    include ::Kl::Primitives::Lists
    include ::Kl::Primitives::GenericFunctions
    include ::Kl::Primitives::Vectors
    include ::Kl::Primitives::Streams
    include ::Kl::Primitives::Time
    include ::Kl::Primitives::Arithmetic

    def initialize
      # The variable namespace
      @variables = {}
    end

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

    # Trampoline-aware function application
    def __apply(fn, args)
      result = fn.call(*args)
      while result.kind_of? ::Kl::Trampoline
        result = result.fn.call(*result.args)
      end
      result
    end

    def __eval(form)
      code = ::Kl::Compiler.compile(form, {}, true)
      result = instance_eval(code)
      # Handle top-level trampolines
      if result.kind_of? ::Kl::Trampoline
        __apply(result.fn, result.args)
      else
        result
      end
    end
  end
end
