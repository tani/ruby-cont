require_relative 'lib/cont/version'
Gem::Specification.new do |spec|
  spec.name          = 'cont'
  spec.version       = Cont::VERSION
  spec.authors       = ['Masaya Taniguchi']
  spec.email         = ['ta2ghc@gmail.com']

  spec.summary       = 'Cont provides methods for working with continuation'
  spec.description   = <<~DESC
    The Cont module provides methods for working with continuations.
    Continuations are a way to save the execution state of a program
    so that it can be resumed later. They are used for advanced control
    flow structures such as coroutines, generators, and so on.

    Ruby have a built-in support for continuations, but it is deprecated
    and should not be used. This implementation uses the 'fiber' library
    based on https://github.com/minoki/delimited-continuations-in-lua .
    That library is released under the MIT license.

    Caution: The continuations of this implementation are 'one-shot',
    So they can only be resumed once. If you try to resume a dead
    continuation, an exception will be raised.
  DESC
  spec.homepage      = 'https://github.com/tani/ruby-cont'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb'] + ['README.md', 'LICENSE.txt']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.23', '>= 5.23.1'
end

