# Cont Library

## Overview

The `Cont` module is a Ruby library that provides an implementation of
continuations using the `fiber` library. Continuations are advanced control flow
constructs that allow you to save the state of a computation at a certain point
and then resume it later. This library is useful for managing complex control
flows and implementing advanced features like coroutines, generators, and
cooperative multitasking.

## Installation

To use the `Cont` library, simply require it in your Ruby project:

```ruby
require 'cont'
```

## Usage

### `Cont.reset`

`Cont.reset` limits the continuation to the current block.
It takes a block of code and returns the result of that block.

#### Example

```ruby
result = Cont.reset do
  # Your code here
  42
end
puts result # => 42
```

### `Cont.shift`

`Cont.shift` captures the current continuation and allows you to resume it.
It takes a block of code, which should call a lambda to resume the continuation.

#### Example

```ruby
result = Cont.reset do
  Cont.shift do |cont|
    cont.call(42) + 1
  end
end
puts result # => 43
```

## Exceptions

### `Cont::DeadContinuationError`

This exception is raised when an attempt is made to resume a dead continuation.

### `Cont::UnexpectedStatusError`

This exception is raised when an unexpected status is encountered.

## License

MIT License

Copyright (c) 2024 Masaya Taniguchi
