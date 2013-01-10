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
          unless fn.kind_of?(Proc) || fn.kind_of?(Symbol)
            raise ::Kl::Error,
                  "The value #{str(fn)} is neither a function nor a symbol."
          end
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
      if @functions.has_key?(f)
        fn = @functions[f]
      else
        coerced_f = Kl::Environment.ruby_to_kl(f)
        if @functions.has_key?(coerced_f)
          fn = @functions[coerced_f]
        else
          super
        end
      end
      coerced_args = args.map { |arg| Kl::Environment.ruby_to_kl(arg)}
      Kl::Environment.kl_to_ruby(__apply(fn, coerced_args))
    end

    def respond_to?(f)
      @functions.has_key?(f) ||
        @functions.has_key?(Kl::Environment.ruby_to_kl(f)) ||
          super
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

      # Coerce Ruby types and conventions to K Lambda
      def kl_to_ruby(x)
        if x.kind_of? Kl::Cons
          x.to_a.map { |y| kl_to_ruby(y) }
        elsif x.kind_of? Symbol
          x.to_s.gsub(/-/, '_').to_sym
        else
          x
        end
      end

      # Coerce K Lambda types and conventions to Ruby
      def ruby_to_kl(x)
        if x.kind_of? Array
          Kl::Cons.list(x.map {|x| ruby_to_kl(x)})
        elsif x.kind_of? Symbol
          x.to_s.gsub(/_/, '-').to_sym
        else
          x
        end
      end
    end
  end
end
