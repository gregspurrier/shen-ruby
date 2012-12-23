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
      @depth = 0
      @trace = false
      @dump_code = false
      @tramp_fn = @tramp_args = @tramp_form = nil
      @variables = {}
      @function_cache = {}
      set("*stinput*".to_sym, STDIN)
      set("*stoutput*".to_sym, STDOUT)
    end

    # Associate proc p with the specified name in the function namespace
    def __defun(name, p)
      eigenklass = class << self; self; end
      eigenklass.send(:define_method, name, p)
      # Invalidate cache
      @function_cache[name] = nil
      name
    end

    def __function(obj)
      case obj
      when Symbol
        cached = @function_cache[obj]
        unless cached
          cached = @function_cache[obj] = method(obj).to_proc.curry
        end
        cached
      when Proc
        obj.curry
      else
        raise "function applied to #{obj.class}"
      end
    end

    # Trampoline-aware function application
    def __apply(fn, args, f)
      if args.any?(&:nil?)
        raise Kl::InternalError, "nil argument to #{f}(#{args})"
      end
      @depth += 1
      puts "--> [#{@depth}] #{f} #{args}" if @trace
      result = fn.call(*args)
      while @tramp_fn
        fn = @tramp_fn
        args = @tramp_args
        f = @tramp_form
        if args.any?(&:nil?)
          raise Kl::InternalError, "nil argument to #{f}(#{args})"
        end
        @tramp_fn = nil
        @tramp_args = nil
        @tramp_form = nil
        puts "tail --> #{f} #{args}" if @trace
        result = fn.call(*args)
      end
      raise Kl::InternalError, "nil result from #{f}(#{args})" if result.nil?
      @depth -= 1
      result
    end

    def __eval(form)
      if @dump_code
        puts "Compiling...."
      end
      code = ::Kl::Compiler.compile(form, {}, true)
      if @dump_code
        puts "=" * 70
        puts code
        puts "=" * 70
      end
      result = instance_eval(code)
      # Handle top-level trampolines
      if @tramp_fn
        fn = @tramp_fn
        args = @tramp_args
        f = @tramp_form
        @tramp_fn = nil
        @tramp_args = nil
        @tramp_form = nil
        __apply(fn, args, f)
      else
        result
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
