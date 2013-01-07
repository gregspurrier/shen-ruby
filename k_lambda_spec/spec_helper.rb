lib_path = File.expand_path("../../lib", __FILE__)
$LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

require 'kl'
require 'stringio'

# Reset the K Lambda environment before every example
RSpec.configure do |config|
  config.before(:each) do
    @kl_env = Kl::Environment.new
  end
end

# Helper function that evaluates a string in the K Lambda environment and
# returns the result as a Ruby object.
def kl_eval(str)
  form = Kl::Reader.new(StringIO.new(str)).next
  @kl_env.__eval(form)
end
