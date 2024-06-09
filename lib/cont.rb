# The Cont module provides methods for working with continuations.
# Continuations are a way to save the execution state of a program
# so that it can be resumed later. They are used for advanced control
# flow structures such as coroutines, generators, and so on.
#
# Ruby have a built-in support for continuations, but it is deprecated
# and should not be used. This implementation uses the 'fiber' library
# based on https://github.com/minoki/delimited-continuations-in-lua .
# That library is released under the MIT license:
# https://github.com/minoki/delimited-continuations-in-lua/blob/master/LICENSE .
#
# Caution 1: The continuations of this implementation are 'one-shot',
# So they can only be resumed once. If you try to resume a dead
# continuation, an exception will be raised.
#
# Caution 2: This implementation is based on the 'fiber' library,
# so you should not crate a new fiber in a continuation block.
#
# Copyright (c) 2024 Masaya Taniguchi
# This software is released under the MIT License.

require_relative 'cont/single_prompt'

module Cont
  include SinglePrompt
  module_function :reset, :shift, :run, :prompt0, :control0
end
