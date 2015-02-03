#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'shen_ruby'

shen = ShenRuby::Shen.new
shen.cd('shen/release/test_programs')
shen.load('README.shen')

# Override y-on-n? so that the script continues on error.
# We must use KLambda's defun to circumvent Shen's protection
# against redefining system functions.
shen.eval_string('(defun y-or-n? (Ignored) true)')

# Reset the pass/fail counters now and then make reset a no-op
# so that we can query it at the end of the test run.
shen.reset
shen.eval_string('(define reset -> true)')

shen.load('tests.shen')
exit(1) unless shen.value(:"test-harness.*failed*") == 0
