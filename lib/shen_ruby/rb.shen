\\ Ruby Interoperability
\\
\\ The rb package provides interoperability with the host Ruby
\\ environment.

(package rb []

\\\\ Parsing of rb.<const-or-method> symbols

(defcc <ruby-extension>
  <rb-dot> "#" <const-name> "." <method-name>
    := [class-method <const-name> <method-name>];
  <rb-dot> "#" <const-name> := [constant <const-name>];
  <rb-dot> "#" <method-name> := [class-method "Kernel" <method-name>];
  <rb-dot> <method-name> := [instance-method <method-name>];)

(defcc <rb-dot> "r" "b" "." := skip;)

(defcc <const-name>
  <const-segment> "#" <const-name> := (@s <const-segment> "::" <const-name>);
  <const-segment> := <const-segment>;)

(defcc <const-segment>
  Cap <const-segment-tail> := (cn Cap <const-segment-tail>)
                              where (capital? Cap);)

(defcc <const-segment-tail>
  <char> <const-segment-tail> := (cn <char> <const-segment-tail>);
  <e> := "";)

(defcc <method-name>
  "-" ">" := "[]=";
  "<" "-" := "[]";
  <char> <method-name> := (cn <char> <method-name>);
  <char> := <char>;)

(defcc <char>
  C := C where (not (or (= C ".") (= C "#"))))

(define capital?
  S -> (element? S [($ ABCDEFGHIJKLMNOPQRSTUVWXYZ)]))

\\\\ Parsing of method argument lists

(defcc <method-invocation>
  Receiver Method <normal-args> <block-args> :=
    [rb-send-block Receiver Method | (append <block-args> <normal-args>)];
  Receiver Method <normal-args> :=
    [rb-send Receiver Method | <normal-args>];)

(defcc <normal-args>
  <kv-pairs> := [(make-hash-constructor <kv-pairs>)];
  <arg> <normal-args> := [<arg> | <normal-args>];
  <e> := [];)

(defcc <kv-pairs>
  <key> <arrow> <val> <kv-pairs> := [[<key> <val>] | <kv-pairs>];
  <key> <arrow> <val> := [[<key> <val>]];)

(defcc <key>
  <arg> := <arg>;)

(defcc <arrow>
  Arrow := Arrow where (= Arrow (intern "=>"));)

(defcc <val>
  <arg> := <arg>;)

(defcc <arg>
  Sym := Sym where (not (or (= Sym (intern "=>"))
                            (and (symbol? Sym)
                                 (= (hdstr (str Sym)) "&"))));)

(defcc <block-args>
  <arity-marker> Expr := [<arity-marker> Expr];)

(defcc <arity-marker>
  X := 1 where (= X (intern "&"));
  X := 0 where (= X (intern "&0"));
  X := 1 where (= X (intern "&1"));
  X := 2 where (= X (intern "&2"));
  X := 3 where (= X (intern "&3"));
  X := 4 where (= X (intern "&4"));
  X := 5 where (= X (intern "&5"));)

(define make-hash-constructor
  Pairs -> (let Temp (gensym (protect Hash))
             [let Temp [rb-send [rb-const "Hash"] "new"]
               [do | (make-hash-load-exprs Pairs Temp)]]))

(define make-hash-load-exprs
  [] Hash -> [Hash]
  [[Key Val] | Pairs] Hash -> [[rb-send Hash "[]=" Key Val] |
                               (make-hash-load-exprs Pairs Hash)])

\\\\ The macros that make the magic

(define parse-ruby-extension
  RbExt -> (trap-error (compile <ruby-extension> (explode RbExt))
                       (/. _ (error
                              (make-string "Invalid Ruby reference: ~A"
                                           RbExt)))))

(define compile-method-invocation
  Receiver Method Args ->
    (trap-error (compile <method-invocation> [Receiver Method | Args])
                (/. _ (error
                       (make-string
                        "Invalid argument syntax for Ruby method '~A': ~A"
                        Method Args)))))

(define expand-method-invocation
  [instance-method Method] [] ->
    (error (make-string "Ruby instance method '~A' has no receiver"
                        Method))
  [instance-method Method] [Receiver | Args] ->
    (compile-method-invocation Receiver Method Args)
  [class-method Class Method] Args ->
    (compile-method-invocation [rb-const Class] Method Args))

(define expand-constant-reference
  [constant Const] -> [rb-const Const]
  \\ Bail out and give the instance method rules a shot
  _ -> (fail))

\\ This function is extremely performance critical because it is used in
\\ the guard expressions of the macro below.
(define ruby-extension?
  RbExt -> (and (rb-send RbExt "instance_of?" (rb-const "Symbol"))
                (rb-send (rb-send RbExt "to_s") "start_with?" "rb.")))

(defmacro desugar-ruby-extensions
  [Method | Args] -> (expand-method-invocation (parse-ruby-extension Method)
                                               Args)
                     where (ruby-extension? Method)
  Const <- (expand-constant-reference (parse-ruby-extension Const))
           where (ruby-extension? Const))

)
