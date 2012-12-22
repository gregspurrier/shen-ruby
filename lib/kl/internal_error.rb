module Kl
  # Internal errors represent inconsistent state within the compiler
  # or runtime environment. They are not catchable by application-level
  # code.
  class InternalError < StandardError
  end
end
