module Kl
  # Absvectors are just arrays. We give them their own subclass
  # to support the absvector? primitive.
  class Absvector < Array
  end
end
