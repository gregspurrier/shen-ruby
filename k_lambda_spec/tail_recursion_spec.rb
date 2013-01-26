require 'spec_helper'

describe 'Tail recursion' do
  it 'does not consume stack space for self tail calls' do
    kl_eval <<-EOS
      (defun count-down (X)
        (if (= X 0)
          success
          (count-down (- X 1))))
    EOS
    kl_eval('(count-down 10000)').should == :success
  end

  it 'does not consume stack space for mutually recursive tail calls' do
    kl_eval <<-EOS
      (defun even? (X)
        (if (= X 1)
          false
          (odd? (- X 1))))
    EOS
    kl_eval <<-EOS
      (defun odd? (X)
        (if (= X 1)
          true
          (even? (- X 1))))
    EOS
    kl_eval('(even? 100000)').should == true
    kl_eval('(odd? 100000)').should == false
  end
end
