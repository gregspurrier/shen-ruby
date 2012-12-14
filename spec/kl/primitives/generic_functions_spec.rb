require 'spec_helper'
require 'kl/primitives/generic_functions'

describe Kl::Primitives::GenericFunctions do
  include Kl::Primitives::GenericFunctions

  describe '=' do
    it 'works as expected for numbers' do
      self.send("=", 1, 1).should be_true
      self.send("=", 1, 1.0).should be_true
      self.send("=", 1, 2).should be_false
    end

    it 'works as expected for symbols' do
      self.send("=", :a, :a).should be_true
      self.send("=", :"big-bad!", :"big-bad!").should be_true
      self.send("=", :"big-bad!", :wolf).should be_false
    end

    it 'works as expected for lists' do
      self.send("=", Kl::Cons.list([1, 2]), Kl::Cons.list([1, 2])).
        should be_true
      self.send("=", Kl::EmptyList.instance, Kl::EmptyList.instance).
        should be_true
      self.send("=", Kl::Cons.list([1, 3]), Kl::Cons.list([1, 2])).
        should be_false
    end
  end
end
