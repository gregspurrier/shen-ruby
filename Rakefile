require 'rubygems'
require 'rspec/core/rake_task'

# Run implementation specs
RSpec::Core::RakeTask.new(:spec)

# Run K Lambda specs
RSpec::Core::RakeTask.new(:k_lambda_spec) do |t|
  t.rspec_opts = '-I k_lambda_spec'
  t.pattern = 'k_lambda_spec/**/*_spec.rb'
end

task :default => [:spec, :k_lambda_spec]
