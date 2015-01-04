#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../shen/lib', __FILE__)
require 'shen_ruby'

shen = ShenRuby::Shen.new
shen.cd('shen/release/test_programs')
shen.load('README.shen')
shen.load('tests.shen')
