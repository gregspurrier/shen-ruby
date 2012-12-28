#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'shen_ruby'

# Load the Shen Envinronment
puts "Loading Shen. This takes a while...."
start = Time.now.to_f
env = ShenRuby::Environment.new
now = Time.now.to_f
puts "Loaded in %0.2f seconds.\n" % (now - start)

# Launch the REPL
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
