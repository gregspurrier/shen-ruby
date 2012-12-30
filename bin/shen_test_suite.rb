#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'shen_ruby'

env = ShenRuby::Environment.new
env.__eval(Kl::Cons.list([:cd, "shen/test_programs"]))
env.__eval(Kl::Cons.list([:load, "README.shen"]))
env.__eval(Kl::Cons.list([:load, "tests.shen"]))
