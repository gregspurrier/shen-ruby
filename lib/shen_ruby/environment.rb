module ShenRuby
  class Environment < Kl::Environment
    def initialize
      super

      # Set the global variables
      set("*language*".to_sym, "Ruby")
      set("*implementation*".to_sym, "#{RUBY_ENGINE} #{RUBY_VERSION}")
      set("*release*".to_sym, RUBY_VERSION)
      set("*port*".to_sym, "0.1.0-SNAPSHOT")
      set("*porters*".to_sym, "Greg Spurrier")
      set("*home-directory*".to_sym, Dir.pwd)
      set("*stinput*".to_sym, STDIN)
      set("*stoutput*".to_sym, STDOUT)


      # Load the K Lambda files
      kl_root = File.expand_path('../../../shen_language/k_lambda', __FILE__)
      %w(toplevel core sys).each do |kl_filename|
        Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
      end

      # Overrides
      class << self
        # Kl::Absvector.new already initializes every element, so we can
        # use a simpler version of vector
        def vector(n)
          v = ::Kl::Absvector.new(n + 1) #, fail)
          v[0] = n
          v
        end

        # The version of shen-explode-string from sys.kl is not tail-recursive.
        # Replace it with a version that does not blow up the stack.
        define_method "shen-explode-string" do |str|
          Kl::Cons.list(str.split(//))
        end

        # Give a way to bail out
        define_method 'quit' do
          ::Kernel.exit(0)
        end

        # For debugging the compiler
        define_method 'set-dump-code' do |val|
          @dump_code = val
        end
      end

      # Load the rest of the K Lambda files
      %w(sequent yacc
         reader prolog track load writer
         macros declarations t-star types
        ).each do |kl_filename|
        Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
      end
    end
  end
end
