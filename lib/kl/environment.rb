require 'kl/primitives/booleans'
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
require 'kl/primitives/extensions'
require 'kl/compiler'

module Kl
  class Environment
    include ::Kl::Primitives::Booleans
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
    include ::Kl::Primitives::Extensions

    def initialize
      @dump_code = false
      @tramp_fn = @tramp_args  = nil
      @variables = Hash.new do |_, k|
        raise Kl::Error, "variable #{k} has no value"
      end
      @functions = Hash.new do |h, k|
        if respond_to? k
          fn = method(k).to_proc
          h[k] = fn
        else
          raise Kl::Error, "The function #{k} is undefined"
        end
      end
      @eigenklass = class << self; self; end
    end

    # Trampoline-aware function application
    def __apply(fn, args)
      while fn
        @tramp_fn = nil
        fn = @functions[fn] if fn.kind_of? Symbol
        arity = fn.arity
        if arity == args.size || arity == -1
          result = fn.call(*args)
        elsif arity > args.size
          # Partial application
          result = fn.curry.call(*args)
        else
          # Uncurrying. Apply fn to its expected number of arguments
          # and hope that the result is a function that can be applied
          # to the remainder.
          fn = __apply(fn, args[0, arity])
          args = args[arity..-1]
          next
        end

        if fn = @tramp_fn
          # Bounce on the trampoline
          args = @tramp_args
          @tramp_args = nil
        end
      end
      result
    rescue SystemStackError
      raise ::Kl::Error, 'maximum stack depth exceeded'
    end

    def __eval(form)
      if @dump_code
        puts "=" * 70
        puts "Compiling:"
        puts Kl::Cons.list_to_string(form)
        puts '-----'
      end
      code = ::Kl::Compiler.compile(form, {}, true)
      if @dump_code
        puts code
        puts "=" * 70
      end
      @tramp_fn = nil
      result = instance_eval(code)
      # Handle top-level trampolines
      if @tramp_fn
        fn = @tramp_fn
        args = @tramp_args
        @tramp_fn = nil
        @tramp_args = nil
        __apply(fn, args)
      else
        result
      end
    end

    def method_missing(f, *args)
      if @functions.has_key? f
        __apply(f, args)
      end
    end

    class << self
      def load_file(env, path)
        File.open(path, 'r') do |file|
          reader = Kl::Reader.new(file)
          while form = reader.next
            env.__eval(form)
          end
        end
      end
    end
  end
end
