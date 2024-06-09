module SinglePrompt

  # The 'fiber' library is required for the implementation of continuations.
  require 'fiber'

  # Exception for handling dead continuation
  class DeadContinuationError < StandardError; end

  # Exception for handling unexpected statuses
  class UnexpectedStatusError < StandardError; end

  # Limit the continuation to the current block.
  #
  # @yield [block] The block of code to be run
  # @return [Object] The result of the block.
  def self.reset(&block)
    prompt0(&block)
  end

  # Capture the current continuation.
  #
  # @yield [block] The block of code to be run
  # @return [Object] The result of the block.
  def self.shift(&block)
    control0 do |fiber|
      prompt0 do
        block.call lambda { |value|
          prompt0 do
            raise DeadContinuationError.new unless fiber.alive?
            run(fiber, :resume, lambda { value })
          end
        }
      end
    end
  end

  private

  def self.run(fiber, *args)
    status, value = fiber.resume(*args)
    case status
    when :return
      value
    when :capture
      value.call(fiber)
    else
      raise UnexpectedStatusError.new("unexpected status: #{status}")
    end
  end

  def self.prompt0(&block)
    fiber = Fiber.new do
      Fiber.yield(:return, block.call())
    end
    run(fiber)
  end

  def self.control0(&block)
    status, f = Fiber.yield(:capture, block)
    raise UnexpectedStatusError.new("unexpected status: #{status}") \
      unless status == :resume
    f.call()
  end
end
