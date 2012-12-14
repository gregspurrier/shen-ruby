require 'spec_helper'

describe Kl::Environment do
  def eval_str(str)
    form = Kl::Reader.new(StringIO.new(str)).next
    @env.__eval(form)
  end

  before(:each) do
    @env = Kl::Environment.new
  end

  describe 'evaluation of atoms' do
    it 'evaluates symbols to themselves' do
      eval_str('foo').should == :foo
      eval_str('foo-bar-<baz>').should == "foo-bar-<baz>".to_sym
    end

    it 'evaluates strings to themselves' do
      eval_str('"foo"').should == 'foo'
      eval_str('"foo #{bar} \'baz"').should == 'foo #{bar} \'baz'
      eval_str('"\\"').should == '\\'
    end

    it 'evaluates numbers to themselves' do
      eval_str('1').should == 1
      eval_str('-1.7').should == -1.7
    end

    it 'evaluates booleans to themselves' do
      eval_str('true').should == true
      eval_str('false').should == false
    end
  end

  describe 'evaluation of non-special forms' do
    it 'evaluates simple function application' do
      eval_str('(+ 1 2)').should == 3
    end

    it 'evaluates function arguments before application' do
      eval_str('(* (+ 1 2) (- 6 1))').should == 15
    end

    it 'supports currying' do
      eval_str('((+ 1) 2)').should == 3
      eval_str('(((+) 1) 2)').should == 3
    end
  end

  describe 'evaluation of lambda special form' do
    it 'evaluates them to proc objects' do
      eval_str('(lambda X X)').should be_kind_of Proc
    end

    it 'allows them to be applied' do
      eval_str('((lambda X X) 37)').should == 37
      eval_str('((lambda X 42) ignore-me)').should == 42
    end

    it 'maintains lexical scoping' do
      # (let X 1
      #   (let Y 3
      #     (let X 7
      #       (+ X Y))))
      eval_str('((lambda X 
                   ((lambda Y 
                      ((lambda X (+ X Y)) 
                        7))
                     3)) 
                   1)').should == 10
    end

    it 'creates closures' do
      eval_str('((let X 37 (lambda IGNORE X)) ignore-me)').should == 37
    end
  end

  describe 'evaluation of let special form' do
    it 'binds its var' do
      eval_str('(let X 37 X)').should == 37
    end

    it 'maintains lexical scoping' do
      eval_str('(let X 1
                  (let Y 3
                    (let X 7
                      (+ X Y))))').should == 10
    end
  end

  describe 'evaluation of defun special form' do
    it 'adds a new function to the environment' do
      eval_str('(defun my-add (A B) (+ A B))').should == "my-add".to_sym
      eval_str('(my-add 17 20)').should == 37
      eval_str('((my-add 17) 20)').should == 37
    end

    it 'exposes the function for use in Ruby' do
      eval_str('(defun add7 (X) (+ X 7))')
      @env.add7(30).should == 37
    end
  end

  describe 'evaluation of boolean special forms' do
    describe "if" do
      before(:each) do
        eval_str('(defun one () 1)')
        eval_str('(defun two () 2)')
      end

      it 'evaluates and returns the true clause when given true' do
        @env.should_receive(:one).and_return(1)
        @env.should_not_receive(:two)
        eval_str('(if true (one) (two))').should == 1
      end

      it 'evaluates and returns the false clause when given false' do
        @env.should_not_receive(:one)
        @env.should_receive(:two).and_return(2)
        eval_str('(if false (one) (two))').should == 2
      end
    end

    describe "and" do
      before(:each) do
        eval_str('(defun tr () true)')
        eval_str('(defun fa () false)')
      end

      it 'returns false and does not evaluate second form if first is false' do
        @env.should_not_receive(:tr)
        eval_str('(and (fa) (tr))').should == false
      end

      it 'returns false when first is true and second is false' do
        eval_str('(and (tr) (fa))').should == false
      end

      it 'returns true when both expressions evaluate to true' do
        @env.should_receive(:tr).twice.and_return(true)
        eval_str('(and (tr) (tr))').should == true
      end
    end

    describe "or" do
      before(:each) do
        eval_str('(defun tr () true)')
        eval_str('(defun fa () false)')
      end

      it 'returns true and does not evaluate second form if first is true' do
        @env.should_not_receive(:fa)
        eval_str('(or (tr) (fa))').should == true
      end

      it 'returns true when first is false and second is true' do
        eval_str('(or (fa) (tr))').should == true
      end

      it 'returns false when both expressions evaluate to false' do
        @env.should_receive(:fa).twice.and_return(false)
        eval_str('(or (fa) (fa))').should == false
      end
    end

    describe "cond" do
      before(:each) do
        eval_str('(defun tr () true)')
        eval_str('(defun fa () false)')
      end

      it 'returns the value of the expression associate with the first true' do
        @env.should_not_receive(:tr)
        eval_str('(cond (false (tr))
                        ((fa) 37)
                        (true 42)
                        (true (tr)))').should == 42
      end

      it 'raises an error upon falling off the end' do
        expect {
          eval_str('(cond (false 37) ((fa) 42))')
        }.to raise_error(Kl::Error, 'no matching case for cond')
      end
    end
  end

  describe "error handling" do
    it 'raises uncaught errors' do
      expect {
        eval_str('(simple-error "boom!")')
      }.to raise_error(Kl::Error, 'boom!')
    end

    it 'moves past caught errors' do
      eval_str('(trap-error 
                  (simple-error "boom!")
                  (lambda E 37))').should == 37          
    end
  end

  describe "setting values" do
    it 'returns the value set' do
      eval_str('(set foo 37)').should == 37
    end

    it 'previously set values are retrievable' do
      eval_str('(set foo 37)')
      eval_str('(value foo)').should == 37
    end
  end
end
