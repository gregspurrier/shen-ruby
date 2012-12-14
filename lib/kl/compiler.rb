module Kl
  module Compiler
    class << self
      def compile(form, lexical_vars = {})
        case form
        when Symbol
          if lexical_vars.has_key?(form)
            mangle_var(form)
          else
            ':"' + form.to_s + '"'
          end
        when String
          # Emit non-interpolating strings
          "'" + escape_string(form) + "'"
        when Kl::Cons
          compile_form(form, lexical_vars)
        when Numeric
          form.to_s
        when true
          'true'
        when false
          'false'
        end
      end

    private
      def compile_form(form, lexical_vars)
        case form.hd
        when :lambda
          compile_lambda(form, lexical_vars)
        when :let
          compile_let(form, lexical_vars)
        else
          compile_application(form, lexical_vars)
        end
      end

      def compile_lambda(form, lexical_vars)
        var = form.tl.hd
        unless var.kind_of? Symbol
          raise 'first argument to lambda must be a symbol'
        end
        # Extend the set of lexical vars
        extended_vars = lexical_vars.dup
        extended_vars[var] = var

        body = form.tl.tl.hd
        '(::Kernel.lambda { |' + mangle_var(var) + '| ' + 
          compile(body, extended_vars) + 
          '})'
      end

      # (let X Y Z) --> ((lambda X Z) Y)
      def compile_let(form, lexical_vars)
        x = form.tl.hd
        y = form.tl.tl.hd
        z = form.tl.tl.tl.hd
        compile(Kl::Cons.list([(Kl::Cons.list([:lambda, x, z])), y]),
                lexical_vars)
      end

      # Normal function application
      def compile_application(form, lexical_vars)
        f = form.hd
        args = form.tl
        '__function(' + compile(f, lexical_vars) + ')' + 
          '.call(' + args.map { |a| compile(a, lexical_vars) }.join(',') + ')'
      end
      
      # Escape single quotes and backslashes
      def escape_string(str)
        new_str = ""
        str.each_char do |c|
          if c == "'"
            new_str << "\\"
            new_str << "'"
          elsif c == '\\'
            new_str << '\\'
            new_str << '\\'
          else
            new_str << c
          end
        end
        new_str
      end

      # Ruby variables cannot start with capital letters. Mangle them.
      def mangle_var(sym)
        '___kl_var_' + sym.to_s
      end
    end
  end
end
