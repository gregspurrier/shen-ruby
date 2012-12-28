#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'shen_ruby'

env = ShenRuby::Environment.new
command = :"shen-shen"
begin
  env.__eval(Kl::Cons.list([command]))
rescue StandardError => e
  # K Lambda simple error
  puts "Ruby exception: #{e.message}"
  # Return to the Shen interpreter without re-printing the credits
  command = :"shen-loop"
  retry
end
