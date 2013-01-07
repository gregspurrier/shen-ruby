# args should be an array containing the components of an example expression.
# E.g., to test partial application of +, you could use:
#
#   include_examples "a partially-applicable function", %w(+ 1 2)
#
# The expression will be evaluated in its fully-expanded form for reference
# and then compared against various partial application scenarios.
shared_examples "partially-applicable function" do |args|
  full_expression = "(#{args.join(' ')})"
  (0...(args.length - 1)).each do |arg_count|
    description = "supports partial application of #{arg_count} argument"
    description << "s" unless arg_count == 1
    it description do
      full_result = kl_eval(full_expression)
      partial_expression = "((#{args[0..arg_count].join(' ')}) #{args[(arg_count + 1)..-1].join(' ')})"
      kl_eval(partial_expression).should == full_result
    end
  end
end
