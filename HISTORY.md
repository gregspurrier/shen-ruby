# ShenRuby Release History

## Not Yet Released
### Features
- Upgrade to Shen 17.2
- Upgrade to Klam 0.0.9 for performance improvements

### Bug Fixes
- Evaluating "c#13;" no longer triggers the message "warning: encountered \r in middle of line, treated as a mere space."

## 0.13.0 - February 3, 2013
### Features
- Upgrade to Shen 17
  - Shen is now BSD-licenesed, making ShenRuby BSD/MIT licenesed

## 0.12.1 - February 1, 2015
### Breaking Changes
- The arity of block arguments to Ruby methods no longer needs to be specified. Now all block arguments are denoted by a `&` followed by the function to pass as the block. Any usages of the old syntax, e.g. `&2`, must be updated to `&`.

## 0.12.0 - January 31, 2015
### Features
- Shen -> Ruby interop
  - See README.md for details

## 0.11.0 - January 15, 2015
### Features
- KLambda implementation switched to [Klam](https://github.com/gregspurrier/klam). This has many implications, including:
  - Significant performance increase. E.g., the Shen Test Suite now runs 2.5 times faster than with ShenRuby 0.10.0.
  - Tail call optimization applies only to self tail calls
  - The environment extends BasicObject rather than Object
  - Shen functions are directly installed as methods on the ShenRuby::Shen instance.
  - Many primitives are inlined.
  - Primitives are less strict with respect to type errors, relying on the Shen type checker to do this work when type checking is enabled.
    - E.g., `(+ "a" "b") no longer throws a type error

### Breaking Changes
- Ruby->Shen interop has changed as a result of the switch to Klam and in preparation for more substantial Ruby<->Shen interop to come. Notably:
  - Underscores in method names are no longer coerced to hyphens before invoking Shen functions. Use `__send__` to invoke Shen functions having names that are not valid Ruby method names.
  - Ruby arrays are no longer automatically coerced to Shen lists and vice versa.

## 0.10.0 - September 19, 2014
### Features
- Upgrade to Shen 16

## 0.9.0 - February 11, 2014
### Features
- Upgrade to Shen 15

## 0.8.1 - January 27, 2014
### Features
- Upgrade to Shen 14.2

## 0.8.0 - November 29, 2013
### Features
- Upgrade to Shen 14

### Misc
- Removed JRuby from "known limitations". ShenRuby runs and passes the test suite under JRuby 1.7.8.

## 0.7.0 - July 3, 2013
### Features
- Upgrade to Shen 13
  - `pr` is no longer a K Lambda primitive
  - `write-byte` added as K Lambda primitive
  - `open` no longer takes stream type as its first argument

### Misc
- Clarify license

## 0.6.0 - June 11, 2013
### Features
- Upgrade to Shen 12

### Bug Fixes
- [KLaSC](https://github.com/gregspurrier/klasc) compliance fixes:
  - if now supports partial application

## 0.5.0 - May 12, 2013
### Features
- Upgrade to Shen 11

### Bug Fixes
- [KLaSC](https://github.com/gregspurrier/klasc) compliance fixes:
  - absvector now raises an error when applied to a negative number

## 0.4.1 - March 21, 2013
### Features
- Upgrade to Shen 9.1

## 0.4.0 - March 15, 2013
### Features
- Upgrade to Shen 9.0

### Bug Fixes
- [Issue 8](https://github.com/gregspurrier/shen-ruby/issues/8) -- `quit` no longer raises a type error when invoked with type checking enabled.
- Fixed many instances of ShenRuby's behavior not matching the Shen CLisp reference implementation:
  - `absvector`, `address->`, `<-address`, `intern`, `n->string`, `pos`, `string->n`, and `tlstr` now throw errors catchable by `trap-error` when type violations occur with their arguments.
  - `tlstr` now raises an error when applied to an empty string
  - `set` and `value` now require their first arugment to be a symbol
  - `hd` and `tl` now raise an error when applied to non-lists
  - `freeze` now supports partial application with zero arguments

## 0.3.1 - January 24, 2013
- No code changes. Updates Gemspec to refer to Shen 8.0.

## 0.3.0 - January 24, 2013
### Features
- Upgrade to Shen 8.0

## 0.2.0 - January 16, 2013
### Features
- Graceful handling of Control-C in ShenRuby REPL [Bruno Deferrari]
- Handle `do` in the K Lambda compiler so that it is eligible for tail call elimination [Bruno Deferrari]
- Ruby->Shen interop
  - Shen functions can now be called from Ruby by invoking the corresponding method on the `ShenRuby::Shen` instance
  - Ruby arrays are coerced back and forth to K Lambda lists
  - Underscores in Ruby symbols are coerced back and forth to hyphens in Shen symbols

### Optimizations
Compared to ShenRuby 0.1.0, 50% faster Shen REPL launch and 38% faster execution of the Shen Test Suite achieved by:
- Faster application of K Lambda primitives when not partially applied
- Inlining of list primitives when not partially applied

### Bug Fixes
- [Issue 4](https://github.com/gregspurrier/shen-ruby/issues/4) -- `and` and `or` may now be partially applied
- [Issue 5](https://github.com/gregspurrier/shen-ruby/issues/4) -- the error raised by applying too many arguments to a function is now caught by `trap-error`.


## 0.1.0 - December 30, 2012
- First public release
- Shen 7.1
- Shen REPL available via `srrepl` executable
