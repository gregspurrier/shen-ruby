# args should be an array containing the components of an example expression.
# E.g., to test partial application of +, you could use:
#
#   include_examples "partially-applicable function", %w(+ 1 2)
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

shared_examples "non-partially-applicable function" do |args|
  (0...(args.length - 1)).each do |arg_count|
    description = "raises an error when given #{arg_count} argument"
    description << "s" unless arg_count == 1
    it description do
      partial_expression = "(#{args[0..arg_count].join(' ')})"
      expect {
        kl_eval(partial_expression)
      }.to raise_error(Kl::Error, "#{args[0]} expects #{args.length - 1} arguments but was given #{arg_count}")
    end
  end
end

# args should be an array containing the components of an example expression.
# E.g., to test applicative order evaluation of +, you could use:
#
#   include_examples "applicative order evaluation", %w(+ 1 2)
shared_examples 'applicative order evaluation' do |args|
  it 'evaluates its arguments from left to right' do
    operator = args.shift
    arg_indexes = (0...args.size).to_a
    instrumented_args = args.zip(arg_indexes).map do |(arg, idx)|
      "(kl-do (set *arg-order* (cn (value *arg-order*) \"#{idx}\")) #{arg})"
    end
    expected = arg_indexes.join

    define_kl_do
    kl_eval('(set *arg-order* "")')
    kl_eval("(#{operator} #{instrumented_args.join(' ')})")
    kl_eval('(value *arg-order*)').should == expected
  end
end

KL_TYPE_EXAMPLES = {
  integer: '1',
  real: '1.0',
  string: '"a string"',
  symbol: 'a-symbol',
  boolean: 'true',
  list: '(cons 1 ())',
  dotted_pair: '(cons 1 2)',
  empty_list: '()',
  function: '(lambda X X)',
  vector: '(absvector 3)'
}

def type_with_article(type)
  name = type.to_s.gsub(/_/, ' ')
  if [:integer, :empty_list].include?(type)
    'an ' + name
  else
    'a ' + name
  end
end

shared_examples 'type predicate' do |predicate, accepted_types|
  accepted_types.each do |type|
    it "returns true when its argument is #{type_with_article(type)}" do
      kl_eval("(#{predicate} #{KL_TYPE_EXAMPLES[type]})").should == true
    end
  end

  it 'returns false when its argument is of any other type' do
    rejected_types = KL_TYPE_EXAMPLES.keys - accepted_types
    rejected_types.each do |type|
      kl_eval("(#{predicate} #{KL_TYPE_EXAMPLES[type]})").should == false
    end
  end
end

POSITION_NAMES = { 1 => 'first', 2 => 'second', 3 => 'third' }

def types_to_s(types)
  if types.length > 2
    types[0..-2].map { |t| type_with_article(t) }.join(', ') +
      ', or ' + type_with_article(types[-1])
  else
    types.map { |t| type_with_article(t) }.join(' or ')
  end
end

shared_examples 'argument types' do |expr, accepted_argument_types|
  accepted_argument_types.to_a.sort.each do |(idx, accepted_types)|
    type_str = types_to_s(accepted_types)
    it "raises an error if its #{POSITION_NAMES[idx]} argument is not #{type_str}" do
      accepted_types.each do |type|
        other_expr = expr.dup
        other_expr[idx] = KL_TYPE_EXAMPLES[type]
        expect {
          kl_eval("(#{other_expr.join(' ')})")
        }.to_not raise_error
      end

      rejected_types = KL_TYPE_EXAMPLES.keys - accepted_types
      rejected_types.each do |type|
        other_expr = expr.dup
        other_expr[idx] = KL_TYPE_EXAMPLES[type]
        expect {
          kl_eval("(#{other_expr.join(' ')})")
        }.to raise_error(Kl::Error, /is not a/)
      end
    end
  end
end
