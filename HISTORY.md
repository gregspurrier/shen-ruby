# ShenRuby Release History

## Not Yet Released
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
