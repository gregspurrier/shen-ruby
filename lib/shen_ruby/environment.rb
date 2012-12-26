module ShenRuby
  class Environment < Kl::Environment
    def initialize
      super

      # Set the global variables
      set("*language*".to_sym, "Ruby")
      set("*implementation*".to_sym, RUBY_ENGINE.to_s)
      set("*release*".to_sym, RUBY_VERSION)
      set("*port*".to_sym, "0.1.0-SNAPSHOT")
      set("*porters*".to_sym, "Greg Spurrier")
      set("*home-directory*".to_sym, Dir.pwd)
      set("*stinput*".to_sym, STDIN)
      set("*stoutput*".to_sym, STDOUT)


      # Load the K Lambda files
      kl_root = File.expand_path('../../../shen_src/k_lambda', __FILE__)
      %w(toplevel core sys).each do |kl_filename|
        puts "Loading #{kl_filename} ..."
        start = Time.now.to_f
        Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
        puts "Done. (%0.2f seconds)" % (Time.now.to_f - start)
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

        # shen-aritycheck-action is only called for its side effects
        # (which come via shen-ahh). The version from core.kl is implemented
        # recursively and sometimes blows out the stack. We replace it here with
        # the following BFS-based implementation that does not bother to return
        # any results.
        define_method 'shen-aritycheck-action' do |form|
          queue = [form]
          until queue.empty?
            f = queue.shift
            if cons?(f)
              send(:"shen-aah", hd(f), tl(f))
              f.each { |x| queue.push(x)}
            end
          end
          :"shen-skip"
        end
      end

      %w(sequent yacc
         reader prolog track load writer
         macros declarations t-star types
        ).each do |kl_filename|
        puts "Loading #{kl_filename} ..."
        start = Time.now.to_f
        Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
        puts "Done. (%0.2f seconds)" % (Time.now.to_f - start)
      end
    end
  end
end
