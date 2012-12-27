require 'kl/compiler'
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

    def initialize
      # The variable namespace
      @depth = 0
      @trace = false
      @dump_code = false
      @tramp_fn = @tramp_args = @tramp_form = nil
      @variables = {}
      @eigenklass = class << self; self; end

      # Methods that refer to instance methods or variables cannot be
      # defined in curried form. Redefine them in curried form on
      # the eigenclass now.
      %w(eval-kl open set value).each do |name|
        @eigenklass.send(:define_method, name, method(name).to_proc.curry)
      end
    end

    # Trampoline-aware function application
    def __apply(fn, args, f)
      @depth += 1
      puts "--> [#{@depth}] #{f} #{args}" if @trace
      if fn.kind_of? Symbol
        begin
          result = send(fn, *args)
        rescue NameError
          raise Kl::Error,  "The function #{f} is undefined"
        end
      else
        result = fn.call(*args)
      end

      while @tramp_fn
        fn = @tramp_fn
        args = @tramp_args
        f = @tramp_form
        @tramp_fn = nil
        @tramp_args = nil
        @tramp_form = nil
        puts "tail --> #{f} #{args}" if @trace
        if fn.kind_of? Symbol
          begin
            result = send(fn, *args)
          rescue NameError
            raise Kl::Error,  "The function #{f} is undefined"
          end
        else
          result = fn.call(*args)
        end
      end
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
