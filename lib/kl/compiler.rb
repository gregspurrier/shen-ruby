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
        when :defun
          compile_defun(form, lexical_vars)
        when :lambda
          compile_lambda(form, lexical_vars)
        when :let
          compile_let(form, lexical_vars)
        when :if
          compile_if(form, lexical_vars)
        when :and
          compile_and(form, lexical_vars)
        when :or
          compile_or(form, lexical_vars)
        else
          compile_application(form, lexical_vars)
        end
      end

      def compile_defun(form, lexical_vars)
        name = form.tl.hd
        arglist = form.tl.tl.hd
        body = form.tl.tl.tl.hd
        
        extended_vars = lexical_vars.dup
        arglist.each { |var| extended_vars[var] = var }
        fn_name = compile(name, {})

        '__defun(' + fn_name + ', ' +
          '(::Kernel.lambda { |' + 
          arglist.map { |var| mangle_var(var) }.join(', ') + '| ' + 
          compile(body, extended_vars) + 
          '})) ; ' + fn_name
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

      def compile_if(form, lexical_vars)
        test_expr = form.tl.hd
        on_true_expr = form.tl.tl.hd
        on_false_expr = form.tl.tl.tl.hd

        compile(test_expr, lexical_vars) + ' ? ' +
          compile(on_true_expr) + " : " +
          compile(on_false_expr)
      end

      def compile_and(form, lexical_vars)
        first_expr = form.tl.hd
        second_expr = form.tl.tl.hd
        compile(first_expr) + ' && ' + compile(second_expr)
      end

      def compile_or(form, lexical_vars)
        first_expr = form.tl.hd
        second_expr = form.tl.tl.hd
        compile(first_expr) + ' || ' + compile(second_expr)
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
