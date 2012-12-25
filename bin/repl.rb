#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'shen_ruby'

env = ShenRuby::Environment.new
begin
  env.__eval(Kl::Cons.list([:"shen-shen"]))
rescue Kl::Error => e
  puts e.message
  retry
end
