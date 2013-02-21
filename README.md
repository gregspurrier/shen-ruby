# ShenRuby
ShenRuby is a Ruby port of the [Shen](http://shenlanguage.org/) programming language. Shen is a modern, functional Lisp that supports pattern matching, currying, and optional static type checking.

ShenRuby supports Shen version 8.0, which was released in January, 2013.

The ShenRuby project has two primary goals. The first is to be a low barrier-to-entry means for Rubyists to explore Shen. To someone with a working installation of Ruby 1.9.3, a Shen REPL is only a gem install away.

Second, ShenRuby aims to enable hybrid applications implemented using a combination of Ruby and Shen. Ruby methods should be able to invoke functions written in Shen and vice versa. Performance is a secondary part of this goal. It should be good enough that, for most tasks, the choice between Ruby and Shen is based primarily on which language is best suited for solving the problem at hand.

ShenRuby 0.1.0 began to satisfy the first goal by providing a Shen REPL accessible from the command line. The second goal is more ambitious and is the subject of ongoing work beginning with the 0.2.0 release and leading up to the eventual 1.0.0 release.

[![Build Status](https://travis-ci.org/gregspurrier/shen-ruby.png)](https://travis-ci.org/gregspurrer/shen-ruby.png)

## Installation
NOTE: ShenRuby requires Ruby 1.9 language features. It has been tested with Ruby 1.9.3-p362. It is not yet working under JRuby or Rubinius.

ShenRuby 0.3.1 is the current release. To install it as gem, use the following command:

    gem install shen-ruby

## Getting started with the Shen REPL

Once the gem has been installed, the Shen REPL can be launched via the `srrepl` (short for ShenRuby REPL) command. For example:

    % srrepl
    Loading.... Completed in 10.29 seconds.
    
    Shen 2010, copyright (C) 2010 Mark Tarver
    www.shenlanguage.org, version 8
    running under Ruby, implementation: ruby 1.9.3
    port 0.3.1 ported by Greg Spurrier
    
    
    (0-) 
    
Please be patient: the Shen REPL takes a while to load (about 10 seconds on a 2.66 GHz MacBook Pro). This will be addressed in future releases.

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

A better way to invoke most Shen functions from Ruby is to simply invoke the corresponding method on the Shen object. If the Shen function's name includes a hyphen, use an underscore instead.

For example, to use the `fizz-buzz` function defined in the previous section to compute the first 20 Fizz Buzz values:

    (1..20).map { |x| shen.fizz_buzz(x) }
    # => ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "Fizz Buzz", "16", "17", "Fizz", "19", "Buzz"] 

The above example uses Ruby's `map` function, but could also have used Shen's version, relying on ShenRuby's interop features to coerce Ruby arrays to and from Shen lists:

    shen.map(:fizz_buzz, (1..20).to_a)
    # => ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "Fizz Buzz", "16", "17", "Fizz", "19", "Buzz"]

Note that the Ruby symbol `:fizz_buzz` is automatically coerced to the Shen symbol `fizz-buzz` so that refer to the function defined above.

As a final example, Ruby functions may be passed as arguments to higher-order Shen functions:

    shen.map(lambda {|x| x * x}, [1, 2, 3, 4, 5])
    # => [1, 4, 9, 16, 25]

#### Caveats
Shen function invocation via methods on the Shen object only works for normal functions. It will not work for special forms like `define`.

The array<->list and underscore<->hyphen automatic coercions do not take effect for Ruby functions that are added to the Shen environment or for the K Lambda [primitives](http://www.shenlanguage.org/documentation/shendoc.htm#The%20Primitive%20Functions%20of%20K%20Lambda) that form the basis of Shen. In practice, this should not be much of a limitation, but it is hoped that this restriction will be lifted in the future.

Shen functions cannot be passed as arguments to functions defined in Ruby. This restriction will be removed in the future.

## Shen Resources

The following resources may be helpful for those wanting to learn more about the Shen programming language:

- [The Shen Website](http://shenlanguage.org/)
- [Learn Shen](http://www.shenlanguage.org/learn-shen/index.html) -- The Shen Website's suggested resources for--and approaches to--learning Shen, including the [Shen in 15 Minutes](http://www.shenlanguage.org/learn-shen/tutorials/shen_in_15mins.html) tutorial for experienced functional programmers.
- [The Shen Official Standard](http://www.shenlanguage.org/Documentation/shendoc.htm)
- [System Functions and their Types in Shen](http://www.shenlanguage.org/learn-shen/system.pdf) -- A reference for all of the standard Shen functions and their types.
- [The Book of Shen](http://www.fast-print.net/bookshop/1278/the-book-of-shen) -- The official guide to the Shen programming language.
- [Shen Google Group](https://groups.google.com/group/qilang?hl=en) -- This is the online forum for discussions related to Shen. Don't be confused by the group's name (Qilang). Qi was the predecessor of Shen and the group retains its name.

## Road Map to 1.0

The following features and improvements are among those planned for ShenRuby as it approaches its 1.0 release:

- Ability to call Ruby methods directly from Shen
- Support for command-line Shen scripts that under ShenRuby
- Support for JRuby and Rubinius
- Thread-safe `ShenRuby::Shen` instances
- Improved performance

## Known Limitations
- The "Qi interpreter - chapter 13" test case in the Shen Test Suite and some of the benchmarks are currently failing with stack overflow errors.
- ShenRuby fails with a stack overflow when run under cygwin on Windows ([Issue #3](https://github.com/gregspurrier/shen-ruby/issues/3)). The Ruby environment installed by [RubyInstaller](http://rubyinstaller.org/), however, is capable of running ShenRuby. It is the recommended environment for running ShenRuby on Windows until the stack overflow issues seen on cygwin can be addressed.
- ShenRuby fails to load under JRuby ([Issue #6](https://github.com/gregspurrier/shen-ruby/issues/6)) and Rubinius ([Issue #])(https://github.com/gregspurrier/shen-ruby/issues/7)].

## Contributors
The following people are gratefully acknowledged for their contributions to ShenRuby:

- Brian Shirai
- Bruno Deferrari

## License
Shen is Copyright (c) 2010-2013 Mark Tarver and released under the Shen License. A copy of the Shen License may be found in [shen/license.txt](https://github.com/gregspurrier/shen-ruby/blob/master/shen/license.txt). A detailed description of the license, along with questions and answers, may be found at http://shenlanguage.org/license.html. The entire contents of the [shen directory](https://github.com/gregspurrier/shen-ruby/tree/master/shen), including the implementation of the `ShenRuby::Shen` class, is part of Shen and is subject to the Shen license.

The remainder of ShenRuby--i.e., everything outside of the shen directory--is Copyright (c) 2012-2013 Greg Spurrier and released under the MIT License. A copy of the MIT License may be found in [MIT_LICENSE.txt](https://github.com/gregspurrier/shen-ruby/blob/master/MIT_LICENSE.txt).
