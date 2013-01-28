############################################################################
# License
# -------
# The user is free to produce commercial applications with the
# software, to distribute these applications in source or binary form,
# and to charge monies for them as he sees fit and in concordance with
# the laws of the land subject to the following license.
# 
# 1. The license applies to all the software and all derived software
# and must appear on such.
#
# 2. It is illegal to distribute the software without this license
# attached to it and use of the software implies agreement with the
# license as such. It is illegal for anyone who is not the copyright
# holder to tamper with or change the license.
#
# 3. Neither the names of Lambda Associates or the copyright holder
# may be used to endorse or promote products built using the software
# without specific prior written permission from the copyright holder.
#
# 4. That possession of this license does not confer on the copyright
# holder any special contractual obligation towards the user. That in
# no event shall the copyright holder be liable for any direct,
# indirect, incidental, special, exemplary or consequential damages
# (including but not limited to procurement of substitute goods or
# services, loss of use, data, or profits; or business interruption),
# however caused and on any theory of liability, whether in contract,
# strict liability or tort (including negligence) arising in any way
# out of the use of the software, even if advised of the possibility
# of such damage.
#
# 5. It is permitted for the user to change the software, for the
# purpose of improving performance, correcting an error, or porting to
# a new platform, and distribute the modified version of Shen
# (hereafter the modified version) provided the resulting program
# conforms in all respects to the Shen standard and is issued under
# that title. The user must make it clear with his distribution that
# he/she is the author of the changes and what these changes are and
# why.
#
# 6. Derived versions of this software in whatever form are subject to
# the same restrictions. In particular it is not permitted to make
# derived copies of this software which do not conform to the Shen
# standard or appear under a different title.
#
# 7. It is permitted to distribute versions of Shen which incorporate
# libraries, graphics or other facilities which are not part of the
# Shen standard.
#
# For an explication of this license see
# http://www.lambdassociates.org/News/june11/license.htm which
# explains this license in full.
#
############################################################################
#
# This file was written by Greg Spurrier as part of the ShenRuby
# project. It is essentially a shell into which the K Lambda sources
# of Shen are loaded at runtime as part of object initialization to
# produce a working Shen environment. It is thefore a derivative work
# of the Shen sources and is subject to the Shen License.
#
############################################################################

module ShenRuby
  # Instances of the ShenRuby::Shen class provide a Shen environment
  # running within ShenRuby's K Lambda implementation.
  class Shen < Kl::Environment
    def initialize
      super

      # Set the global variables
      set("*language*".to_sym, "Ruby")
      set("*implementation*".to_sym, "#{RUBY_ENGINE} #{RUBY_VERSION}")
      set("*release*".to_sym, RUBY_VERSION)
      set("*port*".to_sym, ShenRuby::VERSION)
      set("*porters*".to_sym, "Greg Spurrier")
      set("*home-directory*".to_sym, Dir.pwd)
      set("*stinput*".to_sym, STDIN)
      set("*stoutput*".to_sym, STDOUT)


      # Load the K Lambda files
      kl_root = File.expand_path('../../../release/k_lambda', __FILE__)
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

        # Add a way to evaluate strings, intended for use with Ruby interop.
        # Returns the result of the last expression evaluated.
        # Based on the implementation of read-file in reader.shen
        def eval_string(s)
          forms = __apply(:"read-from-string", [s])
          result = nil
          forms.each { |f| result = __apply(:eval, [f]) }
          result
        end
        alias_method :"eval-string", :eval_string
      end

      # Load the rest of the K Lambda files
      %w(sequent yacc
         reader prolog track load writer
         macros declarations t-star types
        ).each do |kl_filename|
        Kl::Environment.load_file(self, File.join(kl_root, kl_filename + ".kl"))
      end

      # Give type signatures to the new functions added above
      declare :quit, [:'-->', :unit]
      declare :eval_string, [:string, :'-->', :unit]
      declare :'eval-string', [:string, :'-->', :unit]
    end
  end
end
