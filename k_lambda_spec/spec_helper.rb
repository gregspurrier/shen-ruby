lib_path = File.expand_path("../../lib", __FILE__)
$LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

require 'kl'
require 'stringio'

# Load the support files
Dir["./k_lambda_spec/support/**/*.rb"].sort.each {|f| require f}

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

# Defines the 'kl-do' function in the current K Lambda environment. This is
# used instead of 'do' because do is not an official K Lambda primitive
# and may not be found in all K Lambda implementations.
def define_kl_do
  kl_eval('(defun kl-do (X Y) Y)')
end
