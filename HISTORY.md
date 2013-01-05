# ShenRuby Release History

## Not Yet Released
### Features
- Graceful handling of Control-C in ShenRuby REPL [Bruno Deferrari]
- Handle `do` in the K Lambda compiler so that it is eligible for tail call elimination [Bruno Deferrari]
### Optimizations
- Faster application of K Lambda primitives when not partially applied
- List primitives are inlined when not partially applied

## 0.1.0 - December 30, 2012
- First public release
- Shen 7.1
- Shen REPL available via `srrepl` executable
