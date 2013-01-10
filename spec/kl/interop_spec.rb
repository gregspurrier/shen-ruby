require 'spec_helper'

describe 'Ruby->Shen interop' do
  def eval_str(str)
    form = Kl::Reader.new(StringIO.new(str)).next
    @env.__eval(form)
  end

  before(:each) do
    @env = Kl::Environment.new
  end

  it 'allows K Lambda functions to be invoked as methods on environment' do
    eval_str('(defun square (X) (* X X))')
    @env.respond_to?(:square).should be true
    @env.square(7).should == 49
  end

  it 'hides the details of trampolines for tail recursive functions' do
    eval_str('(defun countdown (X) (if (= X 0) true (countdown (- X 1))))')
    @env.countdown(10001).should == true
  end

  it 'coerces underscores to hyphens in function names' do
    eval_str('(defun typical-function-name (X) X)')
    @env.respond_to?(:typical_function_name).should be true
    @env.typical_function_name(37).should == 37
  end

  it 'raises NoMethodError if the function cannot be found' do
    expect {
      @env.undefined_function
    }.to raise_error(NoMethodError)
  end

  describe 'when invoking non-primitives' do
    it 'coerces array arguments to K Lambda lists ' do
      eval_str('(defun first (X) (hd X))')
      @env.first([1, 2, 3]).should == 1
    end

    it 'coerces nested array arguments to K Lambda lists ' do
      eval_str('(defun caadr (X) (hd (hd (tl X))))')
      @env.caadr([1, [2, 3]]).should == 2
    end

    it 'coerces list results to Ruby arrays' do
      eval_str('(defun a-list () (cons 1 (cons 2 ())))')
      @env.a_list.should == [1, 2]
    end

    it 'coerces nested list results to Ruby arrays' do
      eval_str('(defun a-list () (cons 1 (cons (cons 2 (cons 3 ())) ())))')
      @env.a_list.should == [1, [2, 3]]
    end

    it 'coerces underscore to hyphen in symbol arguments' do
      eval_str('(defun foo (X) (set result X))')
      @env.foo(:a_symbol)
      eval_str('(value result)').should == :"a-symbol"
    end

    it 'coerces hyphen to underscore in results' do
      eval_str('(defun foo () a-symbol)')
      @env.foo.should == :a_symbol
    end
  end
end
