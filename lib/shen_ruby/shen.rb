module ShenRuby
  # Instances of the ShenRuby::Shen class provide a Shen environment
  # running within a Klam environment. This class is essentially a loader
  # Shen's KLambda sources and the ShenRuby extensions.
  class Shen < Klam::Environment
    def initialize
      super

      # Set the global variables
      set("*language*".to_sym, "Ruby")
      set("*implementation*".to_sym, "#{::RUBY_ENGINE} #{::RUBY_VERSION}")
      set("*release*".to_sym, ::RUBY_VERSION)
      set("*port*".to_sym, ::ShenRuby::VERSION)
      set("*porters*".to_sym, "Greg Spurrier")
      set("*home-directory*".to_sym, ::Dir.pwd)
      set("*stinput*".to_sym, ::STDIN)
      set("*stoutput*".to_sym, ::STDOUT)
      set("*sterror*".to_sym, ::STDERR)

      # Load the K Lambda files
      kl_root = ::File.expand_path('../../../shen/release/klambda', __FILE__)
      %w(toplevel core sys).each do |kl_filename|
        ::ShenRuby::Shen.load_file(self, ::File.join(kl_root, kl_filename + ".kl"))
      end

      # Overrides
      class << self
        # Give a way to bail out
        def quit
          ::Kernel.exit(0)
        end

        # Add a way to evaluate strings, intended for use with Ruby interop.
        # Returns the result of the last expression evaluated.
        def eval_string(s)
          forms = __send__(:"read-from-string", s)
          result = nil
          while forms
            result = eval(head(forms))
            forms = tail(forms)
          end
          result
        end
        alias_method :"eval-string", :eval_string

        # The performance of `element?` is critical
        def element?(x, l)
          while l
            return true if l.hd == x
            l = l.tl
          end
          return false
        rescue => e
          __send(:"shen.sys-error", :element?)
        end

        def vector(n)
          v = ::Klam::Absvector.new(n + 1, :"shen.fail!")
          v.store(0, n)
          v
        end
      end

      # Load the rest of the K Lambda files
      %w(sequent yacc
         reader prolog track load writer
         macros declarations types t-star
        ).each do |kl_filename|
        ::ShenRuby::Shen.load_file(self, ::File.join(kl_root, kl_filename + ".kl"))
      end

      # Give type signatures to the new functions added above
      declare :quit, cons(:"-->", cons(:unit, nil))
      declare :eval_string, cons(:string, cons(:"-->", cons(:unit, nil)))
      declare :"eval-string", cons(:string, cons(:"-->", cons(:unit, nil)))

      systemf :"rb-const"
      systemf :"rb-send"
      systemf :"rb-send-block"

      old_hush = value(:"*hush*")
      set :"*hush*", true
      load ::File.expand_path('../rb.shen', __FILE__)
      load ::File.expand_path('../shen_ruby.shen', __FILE__)
      set :"*hush*", old_hush
    end

    class << self
      def load_file(env, path)
        ::File.open(path, 'r') do |file|
          reader = ::Klam::Reader.new(file)
          while form = reader.next
            env.__send__(:"eval-kl", form)
          end
        end
      end
    end
  end
end
