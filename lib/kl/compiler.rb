module Kl
  module Compiler
    # The K Lambda primitives are all Ruby functions and never use
    # trampolines. They are all regarded as System Functions and
    # therefore are not allowed to be redefined by the user at
    # run time. Therefore, if all of their arguments have been
    # supplied, it is safe to directly invoke them rather than going
    # incurring the overhead of using __apply. This table holds the
    # arities of the primitives and is used to determine whether
    # direct invocation is possible.
    # Kl::Primitives::Extensions is purposely omitted from this list
    # so that it may be overridden by Shen.
    PRIMITIVE_ARITIES = {}
    [Kl::Primitives::Arithmetic, Kl::Primitives::Assignments,
     Kl::Primitives::Booleans, Kl::Primitives::ErrorHandling,
     Kl::Primitives::GenericFunctions, Kl::Primitives::Lists,
     Kl::Primitives::Streams, Kl::Primitives::Strings,
     Kl::Primitives::Symbols, Kl::Primitives::Time,
     Kl::Primitives::Vectors].each do |prim_mod|
      prim_mod.instance_methods.each do |name|
        PRIMITIVE_ARITIES[name] = prim_mod.instance_method(name).arity
      end
    end

    class << self
      def compile(form, lexical_vars, in_tail_pos)
        case form
        when Symbol
          if lexical_vars.has_key?(form)
            lexical_vars[form]
          else
            escape_symbol(form)
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
        else
          raise Kl::InternalError, "unexpected form: #{form}"
        end
      end

    private
      def compile_form(form, lexical_vars, in_tail_pos)
        case form.hd
        when :defun
          compile_defun(form, lexical_vars)
        when :lambda
          compile_lambda(form, lexical_vars)
        when :let
          compile_let(form, lexical_vars, in_tail_pos)
        when :freeze
          compile_freeze(form, lexical_vars)
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
        when :do
          compile_do(form, lexical_vars, in_tail_pos)
        when :"trap-error"
          compile_trap_error(form, lexical_vars, in_tail_pos)
        # cons, hd, tl, and cons? are crucial to performance and are inlined
        # when all of their arguments are available.
        when :cons
          compile_cons(form, lexical_vars, in_tail_pos)
        when :"cons?"
          compile_consp(form, lexical_vars, in_tail_pos)
        else
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      # (defun NAME ARGS BODY)
      def compile_defun(form, lexical_vars)
        name, arglist, body = destructure_form(form, 3)
        unless name.kind_of? Symbol
          raise Kl::Error, 'first argument to defun must be a symbol'
        end
        unless arglist.all? {|a| a.kind_of? Symbol}
          raise Kl::Error, 'function argument list may only contain symbols'
        end
        if PRIMITIVE_ARITIES.has_key?(name)
          raise Kl::Error, "#{name} is primitive and may not be redefined"
        end

        extended_vars = add_vars(lexical_vars, arglist.to_a)

        fn_name = escape_symbol(name)
        fn_args = arglist.map { |arg| extended_vars[arg] }.join(",")
        fn_body = compile(body, extended_vars, true)

        "(@functions[#{fn_name}] = ::Kernel.lambda { |#{fn_args}| #{fn_body}}; #{fn_name})"
      end

      # (lambda VAR BODY)
      def compile_lambda(form, lexical_vars)
        var, body = destructure_form(form, 2)
        unless var.kind_of? Symbol
          raise Kl::Error, 'first argument to lambda must be a symbol'
        end

        extended_vars = add_var(lexical_vars, var)
        fn_arg = extended_vars[var]
        fn_body = compile(body, extended_vars, true)

        "::Kernel.lambda { |#{fn_arg}| #{fn_body}}"
      end

      # (let VAR EXPR BODY)
      def compile_let(form, lexical_vars, in_tail_pos)
        var, expr, body = destructure_form(form, 3)
        unless var.kind_of? Symbol
          raise Kl::Error, 'first argument to let must be a symbol'
        end

        extended_vars = add_var(lexical_vars, var)
        bound_var = extended_vars[var]
        # The bound expression is evaluated in the original lexical scope
        bound_expr = compile(expr, lexical_vars, false)
        let_body = compile(body, extended_vars, in_tail_pos)

        "(#{bound_var} = #{bound_expr}; #{let_body})"
      end

      # (freeze EXPR)
      def compile_freeze(form, lexical_vars)
        expr = destructure_form(form, 1).first

        body = compile(expr, lexical_vars, true)

        "::Kernel.lambda { #{body} }"
      end

      # (type EXPR T)
      def compile_type(form, lexical_vars, in_tail_pos)
        # Just ignore the type information for now
        expr, _ = destructure_form(form, 2)
        compile(expr, lexical_vars, in_tail_pos)
      end

      # (if TEST_EXPR TRUE_EXPR FALSE_EXPR)
      def compile_if(form, lexical_vars, in_tail_pos)
        test_expr, on_true_expr, on_false_expr = destructure_form(form, 3)

        test_clause = compile(test_expr, lexical_vars, false)
        true_clause = compile(on_true_expr, lexical_vars, in_tail_pos)
        false_clause = compile(on_false_expr, lexical_vars, in_tail_pos)

        "(#{test_clause} ? #{true_clause} : #{false_clause})"
      end

      # (and EXPR1 EXPR2)
      def compile_and(form, lexical_vars, in_tail_pos)
        if form.count == 3
          # This is the special form case
          expr1, expr2 = destructure_form(form, 2)
          compile_if(Kl::Cons.list([:if, expr1, expr2, false]),
                     lexical_vars, in_tail_pos)
        else
          # Partial application falls back to normal application
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      # (or EXPR1 EXPR2)
      def compile_or(form, lexical_vars, in_tail_pos)
        if form.count == 3
          expr1, expr2 = destructure_form(form, 2)
          compile_if(Kl::Cons.list([:if, expr1, true, expr2]),
                     lexical_vars, in_tail_pos)
        else
          # Partial application falls back to normal application
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      def compile_cond(form, lexical_vars, in_tail_pos)
        clauses = form.tl
        if clauses.kind_of? Kl::EmptyList
          'raise(::Kl::Error, "condition failure")'
        else
          clause = clauses.hd
          test_expr = clause.hd
          true_expr = clause.tl.hd
          false_expr = Kl::Cons.new(:cond, clauses.tl)
          compile_if(Kl::Cons.list([:if, test_expr, true_expr, false_expr]),
                     lexical_vars,
                     in_tail_pos)
        end
      end

      # (do EXPR1 EXPR2)
      # 'do' is not a K Lambda primitive, and is defined in the Shen sources as
      # a function that receives two arguments, and returns the last one.
      # 'do' being a function means that the compiler will not see EXPR2 as
      # being in tail-position, inhibiting TCO.
      # To work around this, calls to 'do' are compiled to a sequence of
      # expressions instead of calls to a 'do' function, by doing this, EXPR2
      # has the potential to be in tail position and optimized as such.
      def compile_do(form, lexical_vars, in_tail_pos)
        if form.count == 3
          expr1, expr2 = destructure_form(form, 2)
          body1 = compile(expr1, lexical_vars, false)
          body2 = compile(expr2, lexical_vars, in_tail_pos)
          "(#{body1}; #{body2})"
        else
          # Partial application falls back to normal application
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      # (trap-error EXPR ERR_HANDLER)
      def compile_trap_error(form, lexical_vars, in_tail_pos)
        expr, err_handler = destructure_form(form, 2)

        # TODO: TCO for try and catch clauses
        try_clause = compile(expr, lexical_vars, false)
        extended_vars = add_var(lexical_vars, :err)
        err_var = extended_vars[:err]
        catch_clause = compile_application(
          Kl::Cons.list([err_handler, :err]),
          extended_vars,
          false)

        "(begin; #{try_clause}; rescue ::Kl::Error => #{err_var}; " +
          "#{catch_clause}; end)"
      end

      # Inlined version of (cons HD TL)
      def compile_cons(form, lexical_vars, in_tail_pos)
        if form.count == 3
          hd, tl = destructure_form(form, 2)
          hd_expr = compile(hd, lexical_vars, false)
          tl_expr = compile(tl, lexical_vars, false)
          "::Kl::Cons.new(#{hd_expr}, #{tl_expr})"
        else
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      # Inlined version of (hd L)
      def compile_hd(form, lexical_vars, in_tail_pos)
        if form.count == 2
          expr = compile(form.tl.hd, lexical_vars, false)
          "(#{expr}).hd"
        else
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      # Inlined version of (tl L)
      def compile_tl(form, lexical_vars, in_tail_pos)
        if form.count == 2
          expr = compile(form.tl.hd, lexical_vars, false)
          "(#{expr}).tl"
        else
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      # Inlined version of (cons? X)
      def compile_consp(form, lexical_vars, in_tail_pos)
        if form.count == 2
          expr = compile(form.tl.hd, lexical_vars, false)
          "(#{expr}).kind_of?(::Kl::Cons)"
        else
          compile_application(form, lexical_vars, in_tail_pos)
        end
      end

      # Normal function application
      def compile_application(form, lexical_vars, in_tail_pos)
        f = form.hd
        args = form.tl

        if PRIMITIVE_ARITIES[f] == args.count
          # This is a non-partial primitive application. No need for __apply
          # or trampolines.
          send_args = form.map {|f| compile(f, lexical_vars, false)}.join(',')
          "send(#{send_args})"
        else
          rator = compile(f, lexical_vars, false)
          rands = args.map { |arg| compile(arg, lexical_vars, false) }.join(',')

          if in_tail_pos
            tfn = gen_sym
            targs = gen_sym

            "(
               #{tfn} = #{rator};
               #{targs} = [#{rands}];
               @tramp_fn = #{tfn};
               @tramp_args = #{targs}
              )"
          else
            "__apply(#{rator}, [#{rands}])"
          end
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

      def escape_symbol(sym)
        ':"' + sym.to_s + '"'
      end

      def destructure_form(form, expected_arg_count)
        array = form.to_a
        unless array.length == expected_arg_count + 1
          raise Kl::Error, "#{form.first} expects #{expected_arg_count} " +
            "arguments but was given #{array.length - 1}"
        end
        array[1..-1]
      end

      def add_var(scope, var)
        add_vars(scope, [var])
      end

      def add_vars(scope, vars)
        scope.dup.tap do |new_scope|
          vars.each do |var|
            new_scope[var] = gen_sym
          end
        end
      end

      def gen_sym
        @sym_count ||= 0
        @sym_count += 1
        "__kl_VAR_#{@sym_count}"
      end
    end
  end
end
