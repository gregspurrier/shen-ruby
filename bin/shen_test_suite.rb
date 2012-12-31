#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../shen/lib', __FILE__)
require 'shen_ruby'

shen = ShenRuby::Shen.new
shen.__eval(Kl::Cons.list([:cd, "shen/release/test_programs"]))
shen.__eval(Kl::Cons.list([:load, "README.shen"]))
shen.__eval(Kl::Cons.list([:load, "tests.shen"]))
