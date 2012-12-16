module Kl
  # Trampolines hold a function and a list of its already-evaluated
  # arguments. They are used to keep the strack from growing on
  # tail calls.
  class Trampoline
    attr_reader :fn, :args, :f
    
    def initialize(fn, args, f)
      @fn = fn
      @args = args
      @f = f
    end
  end
end
