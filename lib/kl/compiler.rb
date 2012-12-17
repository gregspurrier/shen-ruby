module Kl
  module Compiler
    class << self
      def compile(form, lexical_vars, in_tail_pos)
        case form
        when Symbol
          if lexical_vars.has_key?(form)
            lexical_vars[form]
          else
            ':"' + form.to_s + '"'
          end
        when String
          # Emit non-interpolating strings
          "'" + escape_string(form) + "'"
        when Kl::Cons
          compile_form(form, lexical_vars, in_tail_pos)
        when Kl::EmptyList
          "::Kl::EmptyList.instance"
        when Numeric
          form.to_s
        when true
          'true'
        when false
          'false'
        end
      end

    private
      def compile_form(form, lexical_vars, in_tail_pos)
        case form.hd
        when :defun
          compile_defun(form, lexical_vars, in_tail_pos)
        when :lambda
          compile_lambda(form, lexical_vars, in_tail_pos)
        when :let
          compile_let(form, lexical_vars, in_tail_pos)
        when :freeze
          compile_freeze(form, lexical_vars, in_tail_pos)
        when :type
          compile_type(form, lexical_vars, in_tail_pos)
        when :if
          compile_if(form, lexical_vars, in_tail_pos)
        when :and
          compile_and(form, lexical_vars, in_tail_pos)
        when :or
          compile_or(form, lexical_vars, in_tail_pos)
        when :cond
          compile_cond(form, lexical_vars, in_tail_pos)
        when :"trap-error"
          compile_trap_error(form, lexical_vars, in_tail_pos)
        else
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      def compile_defun(form, lexical_vars, in_tail_pos)
        name = form.tl.hd
        arglist = form.tl.tl.hd
        body = form.tl.tl.tl.hd
        
        extended_vars = lexical_vars.dup
        arglist.each { |var| extended_vars[var] = gen_sym }
        fn_name = compile(name, {}, false)

        '__defun(' + fn_name + ', ' +
          '(::Kernel.lambda { |' + 
          arglist.map { |var| extended_vars[var] }.join(', ') + '| ' + 
          compile(body, extended_vars, true) + 
          '})) ; ' + fn_name
      end

      def compile_lambda(form, lexical_vars, in_tail_pos)
        var = form.tl.hd
        unless var.kind_of? Symbol
          raise 'first argument to lambda must be a symbol'
        end
        # Extend the set of lexical vars
        extended_vars = lexical_vars.dup
        extended_vars[var] = gen_sym

        body = form.tl.tl.hd
        '(::Kernel.lambda { |' + extended_vars[var] + '| ' + 
          compile(body, extended_vars, true) + 
          '})'
      end

      # (let X Y Z)
      def compile_let(form, lexical_vars, in_tail_pos)
        x = form.tl.hd
        y = form.tl.tl.hd
        z = form.tl.tl.tl.hd
        extended_vars = lexical_vars.dup
        extended_vars[x] = gen_sym
        
        '(' + extended_vars[x] + ' = ' + compile(y, extended_vars, false) + '; '+
          compile(z, extended_vars, in_tail_pos) + ')'
      end

      def compile_freeze(form, lexical_vars, in_tail_pos)
        form = form.tl.hd
        '::Kernel.lambda {' + compile(form, lexical_vars, true) + '}'
      end

      def compile_type(form, lexical_vars, in_tail_pos)
        # Just ignore the type information for now
        compile(form.tl.hd, lexical_vars, in_tail_pos)
      end

      def compile_if(form, lexical_vars, in_tail_pos)
        test_expr = form.tl.hd
        on_true_expr = form.tl.tl.hd
        on_false_expr = form.tl.tl.tl.hd

        compile(test_expr, lexical_vars, false) + ' ? ' +
          compile(on_true_expr, lexical_vars, in_tail_pos) + " : " +
          compile(on_false_expr, lexical_vars, in_tail_pos)
      end

      def compile_and(form, lexical_vars, in_tail_pos)
        first_expr = form.tl.hd
        second_expr = form.tl.tl.hd
        compile(first_expr, lexical_vars, false) + ' && ' + 
          compile(second_expr, lexical_vars, in_tail_pos)
      end

      def compile_or(form, lexical_vars, in_tail_pos)
        first_expr = form.tl.hd
        second_expr = form.tl.tl.hd
        compile(first_expr, lexical_vars, false) + ' || ' + 
          compile(second_expr, lexical_vars, in_tail_pos)
      end

      def compile_cond(form, lexical_vars, in_tail_pos)
        clauses = form.tl
        if clauses.kind_of? Kl::EmptyList
          'raise(::Kl::Error, "condition failure")'
        else
          clause = clauses.hd
          rest = clauses.tl
          compile_if(Kl::Cons.list([:if, clause.hd, clause.tl.hd,
                                    Kl::Cons.new(:cond, rest)]),
                     lexical_vars, in_tail_pos)
        end
      end


      def compile_trap_error(form, lexical_vars, in_tail_pos)
        try_expr = form.tl.hd
        handler_expr = form.tl.tl.hd
        extended_vars = lexical_vars.dup
        err_sym = :err
        extended_vars[err_sym] = gen_sym
        # FIXME: the expression within the begin block should propagate
        # in_tail_pos.
        '(begin; ' +
          compile_form(try_expr, lexical_vars, false) + 
          '; rescue ::Kl::Error => ' + extended_vars[err_sym] + '; ' +
          compile_application(Kl::Cons.list([handler_expr, err_sym]),
                              extended_vars, in_tail_pos) +
          '; end)'
      end

      # Normal function application
      def compile_application(form, lexical_vars, in_tail_pos)
        f = form.hd
        args = form.tl
        
        rator = '__function(' + compile(f, lexical_vars, false) + ')'
        rands = args.map { |a| compile(a, lexical_vars, false) }.join(',')

        tfn = gen_sym
        targs = gen_sym

        if in_tail_pos
          "(
             #{tfn} = #{rator};
             #{targs} = [#{rands}];
             @tramp_fn = #{tfn};
             @tramp_args = #{targs};
             @tramp_form = #{compile(f.to_s, lexical_vars, false)};
            )"
        else
          '__apply(' + rator + ', [' + rands + '], ' + compile(f.to_s, lexical_vars, false) + ')'
        end
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

      def gen_sym
        @sym_count ||= 0
        @sym_count += 1
        "__kl_VAR_#{@sym_count}"
      end
    end
  end
end
