# ShenRuby
ShenRuby is a Ruby port of the [Shen](http://shenlanguage.org/) programming language. Shen is a modern, functional Lisp that supports pattern matching, currying, and optional static type checking.

ShenRuby supports Shen version 7.1, which was released in December, 2012.

The ShenRuby project has two primary goals. The first is to be a low barrier-to-entry means for Rubyists to explore Shen. To someone with a working installation of Ruby 1.9.3, a Shen REPL is only a gem install away.

Second, ShenRuby aims to enable hybrid applications implemented using a combination of Ruby and Shen. Ruby methods should be able to invoke functions written in Shen and vice versa. Performance is a secondary part of this goal. It should be good enough that, for most tasks, the choice between Ruby and Shen is based primarily on which language is best suited for solving the problem at hand.

ShenRuby 0.1.0 begins to satisfy the first goal by providing a Shen REPL accessible from the command line. The second goal is more ambitious and is the subject of ongoing work leading to the eventual 1.0.0 release.

## Installation
NOTE: ShenRuby requires Ruby 1.9 language features. It has been tested with Ruby 1.9.3 and, to a lesser extent, Rubnius in 1.9 mode. It it not yet passing the Shen Test Suite under JRuby.

ShenRuby 0.1.0 is the current release. To install it as gem, use the following command:

    gem install shen-ruby

## Getting started with the Shen REPL

Once the gem has been installed, the Shen REPL can be launched via the `srrepl` (short for ShenRuby REPL) command. For example:


    % srrepl
    Loading Shen.... Completed in 18.61 seconds.
    
    Shen 2010, copyright (C) 2010 Mark Tarver
    www.shenlanguage.org, version 7.1
    running under Ruby, implementation: ruby 1.9.3
    port 0.1.0 ported by Greg Spurrier
    
    
    (0-) 
    
Please be patient: the Shen REPL takes a while to load (about 20 seconds on a 2.66 GHz MacBook Pro). This will be addressed in future releases.

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

## Shen Resources

The following resources may be helpful for those wanting to learn more about the Shen programming language:

- [The Shen Website](http://shenlanguage.org/)
- [Learn Shen](http://www.shenlanguage.org/learn-shen/index.html) -- The Shen Website's suggested resources for--and approaches to--learning Shen, including the [Shen in 15 Minutes](http://www.shenlanguage.org/learn-shen/tutorials/shen_in_15mins.html) tutorial for experienced functional programmers.
- [The Shen Official Standard](http://www.shenlanguage.org/Documentation/shendoc.htm)
- [System Functions and their Types in Shen](http://www.shenlanguage.org/learn-shen/system.pdf) -- A reference for all of the standard Shen functions and their types.
- [The Book of Shen](http://www.shenlanguage.org/tbos.html) -- The official guide to the Shen programming language. The first printing quickly sold out, but another printing is expected in January, 2013. See this [discussion](https://groups.google.com/d/topic/qilang/V8so3Rirkk0/discussion) on the Shen News Group for the most up-to-date information.
- [Shen Google Group](https://groups.google.com/group/qilang?hl=en) -- This is the online forum for discussions related to Shen. Don't be confused by the group's name (Qilang). Qi was the predecessor of Shen and the group retains its name.

## Road Map to 1.0

The following features and improvements are among those planned for ShenRuby as it approaches its 1.0 release:

- Ability to call Shen functions directly from Ruby
- Ability to call Ruby methods directly from Shen
- Support for command-line Shen scripts that under ShenRuby
- Support for MRI, JRuby, and Rubinius
- Improved performance

## Known Limitations

The "Qi interpreter - chapter 13" test case in the Shen Test Suite and some of the benchmarks are currently failing with stack overflow errors.

## License
Shen is Copyright (c) 2010-2012 Mark Tarver and released under the Shen License. A copy of the Shen License may be found in [shen/license.txt](shen/licenese.txt). A detailed description of the license, along with questions and answers, may be found at http://shenlanguage.org/license.html. The entire contents of the [shen directory](shen), including the implementation of the `ShenRuby::Shen` class, is part of Shen and is subject to the Shen license.

The remainder of ShenRuby--i.e., everything outside of the shen directory--is Copyright (c) 2012 Greg Spurrier and released under the MIT License. A copy of the MIT License may be found in [MIT_LICENSE.txt](MIT_LICENSE.txt).
