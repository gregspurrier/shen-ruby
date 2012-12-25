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

      # Load the K Lambda files
      kl_root = File.expand_path('../../../shen_src/k_lambda', __FILE__)
      %w(toplevel core sys).each do |kl_filename|
#        puts "Loading #{kl_filename} ..."
        Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
#        puts "Done"
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
      end

      %w(sequent yacc
         reader prolog track load writer
         macros declarations t-star
        ).each do |kl_filename|
        puts "Loading #{kl_filename} ..."
        Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
        puts "Done"
      end

#      @dump_code = true
#      RubyProf.start
#      __eval(Kl::Cons.list([:cd, "/Users/gspurrie/Downloads/Shen 7.1/Test Programs"]))
#      __eval(Kl::Cons.list([:load, "README.shen"]))
             
                           
#      __eval(Kl::Cons.list([:load, "/Users/gspurrie/Downloads/Shen 7.1/Test Programs/README.shen"]))
#      @trace = true
#      __eval(Kl::Cons.list([:load, "/Users/gspurrie/Downloads/Shen 7.1/Test Programs/tests.shen"]))
#      result = RubyProf.stop
#      printer = RubyProf::FlatPrinter.new(result)
#      printer.print(STDOUT)

#      @trace = true

      #%w(types).each do |kl_filename|
      #  puts "Loading #{kl_filename} ..."
      #  Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
      #  puts "Done"
      #end
    end
  end
end
