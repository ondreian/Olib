module Psycellium
  ## All message types
  module DSL
    ## anonymous TCP socket wants to declare who it is
    ATTACH   = 1
    MESSAGE  = 1 << 1
    RESPONSE = 1 << 2
    REQUEST  = 1 << 3
    NODES    = 1 << 4
  end
end