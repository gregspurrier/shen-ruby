# ShenRuby
ShenRuby is a Ruby port of the [Shen](http://shenlanguage.org/) programming language. Shen is a modern, functional Lisp that supports pattern matching, currying, and optional static type checking.

ShenRuby supports Shen version 17.2, which was released in February, 2015.

The ShenRuby project has two primary goals. The first is to be a low barrier-to-entry means for Rubyists to explore Shen. To someone with a working installation of Ruby 1.9.3 or greater, a Shen REPL is only a gem install away.

Second, ShenRuby aims to enable hybrid applications implemented using a combination of Ruby and Shen. Ruby methods should be able to invoke functions written in Shen and vice versa. Performance is a secondary part of this goal. It should be good enough that, for most tasks, the choice between Ruby and Shen is based primarily on which language is best suited for solving the problem at hand.

ShenRuby 0.1.0 began to satisfy the first goal by providing a Shen REPL accessible from the command line. The second goal is more ambitious and is the subject of ongoing work leading up to the eventual 1.0.0 release.

[![Build Status](https://travis-ci.org/gregspurrier/shen-ruby.png)](https://travis-ci.org/gregspurrier/shen-ruby)

## Installation
NOTE: ShenRuby requires Ruby 1.9 language features. It is tested with Ruby 2.0.0, 2.1.5, and 2.2.0. It has been lightly tested with JRuby 1.7.17. It is functional with Ruby 1.9.3, however its fixed stack size prevents it from passing the Shen Test Suite (see [Setting Stack Size](setting-stack-size) below).

ShenRuby 0.14.0 is the current release. To install it as a gem, use the following command:

    gem install shen-ruby

## Getting started with the Shen REPL

Once the gem has been installed, the Shen REPL can be launched via the `srrepl` (short for ShenRuby REPL) command. For example:

    Loading.... Completed in 2.01 seconds.

    Shen, copyright (C) 2010-2015 Mark Tarver
    www.shenlanguage.org, Shen 17.2
    running under Ruby, implementation: ruby 2.2.0
    port 0.14.0 ported by Greg Spurrier


    (0-)

The `(0-)` seen above is the Shen REPL prompt. The number in the prompt increases after each expression that is entered.

Here is an example of defining a recursive factorial function via the REPL and trying it out:

    (0-) (define factorial
           0 -> 1
           X -> (* X (factorial (- X 1))))
    factorial

    (1-) (factorial 5)
    120

    (2-) (factorial 20)
    2432902008176640000

    (3-) (factorial 100)
    93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000

Shen functions are defined in terms of pattern matching rules. Above we say that the factorial of 0 is 1 and that the factorial of anything else--represented as the variable `X`--is `X` times the factorial of `(X - 1)`. This is very similar to how factorial would be described via mathematical equations.

As can be seen with `(factorial 100)`, ShenRuby uses Ruby's underlying number system and supports arbitrarily large integers.

For a quick tour of Shen via the REPL, please see the [Shen in 15 Minutes](http://www.shenlanguage.org/learn-shen/tutorials/shen_in_15mins.html) tutorial on the Shen Website. To learn more about using the Shen REPL itself, please see the [REPL](http://www.shenlanguage.org/learn-shen/repl.html) documentation, also on the Shen Website. Additional resources for learning about Shen are listed in the Shen Resources section below.

To exit the Shen REPL, execute the `quit` function:

    (4-) (quit)
    %

## Ruby<->Shen Interop
Bidirectional interaction between Ruby and Shen is a primary goal of ShenRuby. The following sections describe the currently supported means of collaboration between Shen and Ruby.

These APIs should be considered experimental and likely to evolve as ShenRuby progresses toward 1.0.

### Extending the Shen Environment with Ruby Functions

The Shen Environment may be extended with functions written in Ruby. Any instance method added to the ShenRuby::Shen class--whether through subclassing or adding methods to an instance's eigenclass--is available for invocation from within Shen.

For example, to add a `divides?` function to an existing Shen environment object:

    require 'rubygems'
    require 'shen_ruby'

    shen = ShenRuby::Shen.new
    class << shen
      def divides?(a, b)
        b % a == 0
      end
    end

### Evaluating Shen Expressions from Ruby
`ShenRuby::Shen#eval_string` takes a string and evaluates it as a Shen expression within the environment. For example, the `divides?` function added above may be invoked with:

    shen.eval_string "(divides? 3 9)"
    # => true

More commonly, though, `eval_string` is used with Shen `define` expressions to extend the environment with new functions that are implemented in Shen. For example, let's add a [Fizz Buzz](http://en.wikipedia.org/wiki/Fizz_buzz) function:

    shen.eval_string <<-EOS
      (define fizz-buzz
        X -> "Fizz Buzz" where (and (divides? 3 X)
                                   (divides? 5 X))
        X -> "Fizz" where (divides? 3 X)
        X -> "Buzz" where (divides? 5 X)
        X -> (str X))
    EOS
    # => :"fizz-buzz"

### Invoking Shen Functions from Ruby

Shen functions are instance methods of the ShenRuby::Shen environment object. Functions having names that are valid Ruby method names may be invoked directly:

    shen.cn("Hello, ", "Shen!")
    # => "Hello, Shen!"

If the Shen function's name is not a valid Ruby method name--e.g. it includes a hyphen--it can be invoked via `__send__`:

    shen.__send__('fizz-buzz', 15)
    # => "Fizz Buzz"

Ruby arrays must be converted to Shen lists or vectors before passing to Shen. Here is an example of converting an array to a list, invoking Shen's `map` function, and converting the resulting list back to a Ruby array:

    ShenRuby.list_to_array(shen.map(:'fizz-buzz', ShenRuby.array_to_list((1..20).to_a)))
    => ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "Fizz Buzz", "16", "17", "Fizz", "19", "Buzz"]

The equivalent conversion functions for vectors are `ShenRuby.vector_to_list` and `ShenRuby.list_to_vector`.

#### Caveats
Shen function invocation via methods on the Shen object only works for normal functions. It will not work for special forms like `define` or macros.

### Invoking Ruby from Shen
By convention, functionality for interacting with Shen's host platform is placed within a package named with the host language's file extension. Therefore the Ruby interop forms begin with `rb.`.

#### Constant References
Ruby constants, including classes and modules, are referenced by prefixing them with `rb.#` and replacing `::` with `#`. For example:

    rb.#Hash
    rb.#Math#PI
    rb.#RUBY_VERSION

### Method Invocation
Ruby method invocation uses a syntax inspired by Clojure and looks similar to normal function application. The method name, prefixed with `rb.`, is used as the operator and the receiver is the first operand. Any additional operands are passed to the method as its arguments. For example:

    (rb.reverse "hello")
    (rb.prepend "bye" "good")
    (rb.sqrt rb.#Math 4)

The `[]` and `[]=` method names used for accessing and manipulating Ruby arrays and hashes cannot be used directly because the Shen reader interprets `[]` as an empty list. Use `rb.<-` and `rb.->` instead. These mimic Shen's `<-vector` and `vector->` operations on vectors.

#### Invoking Class Methods
The last example above invokes the `Math` module's `sqrt` class method. A shorter form is provided as a convenience:

    (rb.#Math.sqrt 4)

Invocations of `Kernel` class methods can be further shortened by prefixing the method's name with `rb.#`. The following are all equivalent:

    (rb.require rb.#Kernel "digest/md5")
    (rb.#Kernel.require "digest/md5")
    (rb.#require "digest/md5")

#### Hash Parameters
Many Ruby methods take a `Hash` object as their final parameter. Ruby provides a special syntax for this which is echoed by ShenRuby. Argument triples of the form 'key `=>` value' are poured into `Hash` and passed as the method's final argument. For example:

    (rb.#puts a => "hello" b => 37)

As in Ruby, the key-arrow-value triples must be the final normal arguments to the method.

#### Block Parameters
In addition to normal arguments, Ruby methods may also accept blocks. A block argument in ShenRuby is denoted by the symbol `&` followed by a function. These must be the final two elements in the method's argument list.

For example, to print each character of a string on a separate line using Shen's `pr` and `nl` system functions:

    (rb.each_char "hello" & (/. X (do (pr X) (nl))))

Or, to sum the elements of a list using Ruby's `Enumerable#reduce`:

    (rb.reduce [1 2 3] & +)

This use of `reduce` is possible because Shen's list and vector types are enumerable in ShenRuby.

Please note that these two examples can--and, in practice, should--be easily implemented in Shen without resorting to Ruby methods. They are here simply to demonstrate ShenRuby's syntax for block arguments.

#### Type Coercion
Shen booleans, numbers, strings, and symbols are implemented using the corresponding Ruby classes and no coercion is required.

Shen's list and vector types both implement the Ruby `Enumerable` interface and may be passed directly as arguments to methods expecting instances of `Enumerable`. When an `Array` is required, they can be coerced using `rb.to_a`.

ShenRuby provides two system functions for coercing Ruby `Enumerable` instances to Shen lists and vectors. These are `rb-to-l` and `rb-to-v`, respectively.

## Setting Stack Size
Some operations in Shen, notably type checking of complicated types, require more stack space than is available by default in Ruby. If your program encounters a stack overflow, you can increase Ruby's stack size through the following methods.

### Ruby
Beginning in Ruby 2.0.0, the MRI stack size can be overridden via the `RUBY_THREAD_VM_STACK_SIZE` environment variable. A value of 2097152 is sufficient for the Shen Test Suite to pass under both OS X and Linux.

### JRuby
JRuby uses the JVM's stack. It can be increased via the `-J-Xss` command line argument. A value of 32m (i.e., `-J-Xss32m`) is sufficient for the Shen Test Suite to pass under both OS X and Linux.

## Shen Resources

The following resources may be helpful for those wanting to learn more about the Shen programming language:

- [The Shen Website](http://shenlanguage.org/)
- [Learn Shen](http://www.shenlanguage.org/learn-shen/index.html) -- The Shen Website's suggested resources for--and approaches to--learning Shen, including the [Shen in 15 Minutes](http://www.shenlanguage.org/learn-shen/tutorials/shen_in_15mins.html) tutorial for experienced functional programmers.
- [The Shen Official Standard](http://www.shenlanguage.org/Documentation/shendoc.htm)
- [System Functions and their Types in Shen](http://www.shenlanguage.org/learn-shen/system.pdf) -- A reference for all of the standard Shen functions and their types.
- [The Book of Shen (Second Edition)](http://www.fast-print.net/bookshop/1506/the-book-of-shen-second-edition) -- The official guide to the Shen programming language.
- [Shen Google Group](https://groups.google.com/group/qilang?hl=en) -- This is the online forum for discussions related to Shen.

## Road Map to 1.0

The following features and improvements are among those planned for ShenRuby as it approaches its 1.0 release:

- Support for command-line Shen scripts that under ShenRuby
- Support for Rubinius
- Thread-safe `ShenRuby::Shen` instances

## Known Limitations
- ShenRuby fails with a stack overflow when run under cygwin on Windows ([Issue #3](https://github.com/gregspurrier/shen-ruby/issues/3)). The Ruby environment installed by [RubyInstaller](http://rubyinstaller.org/), however, is capable of running ShenRuby. It is the recommended environment for running ShenRuby on Windows until the stack overflow issues seen on cygwin can be addressed.
- ShenRuby fails to load under Rubinius ([Issue #7])(https://github.com/gregspurrier/shen-ruby/issues/7)].

## Contributors
The following people are gratefully acknowledged for their contributions to ShenRuby:

- Brian Shirai
- Bruno Deferrari

## License
The implementation of Shen, which is found in the [shen](https://github.com/gregspurrier/shen-ruby/tree/master/shen) directory, is Copyright (c) 2010-2015 Mark Tarver and released under the BSD license. A copy of the license may be found in [shen/release/BSD](https://github.com/gregspurrier/shen-ruby/tree/master/shen/release/BSD).

The remainder of ShenRuby is Copyright(c) 2012-2015 Greg Spurrier and released under the MIT license. A copy of the license may be found in [MIT_LICENSE.txt](https://github.com/gregspurrier/shen-ruby/blob/master/MIT_LICENSE.txt).
