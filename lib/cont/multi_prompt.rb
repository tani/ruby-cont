module MultiPrompt

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
  def reset_at(tag, &block)
    prompt0_at(tag, &block)
  end

  # Capture the current continuation.
  #
  # @yield [block] The block of code to be run
  # @return [Object] The result of the block.
  def shift_at(tag, &block)
    control0_at(tag) do |fiber|
      prompt0_at(tag) do
        block.call lambda { |value|
          prompt0_at(tag) do
            raise DeadContinuationError.new unless fiber.alive?
            run_at(nil, fiber, :resume, lambda { value })
          end
        }
      end
    end
  end

  def run_at(tag, fiber, *args)
    case fiber.resume(*args)
    in :return, value
      value
    in :capture, ^tag, value
      value.call(fiber)
    in :capture, other_tag, value
        run_at(tag, fiber, Fiber.yield(:capture, other_tag, value))
    else
      raise UnexpectedStatusError.new("unexpected status")
    end
  end

  def prompt0_at(tag, &block)
    fiber = Fiber.new do
      Fiber.yield(:return, block.call())
    end
    run_at(tag, fiber)
  end

  def control0_at(tag, &block)
    status, f = Fiber.yield(:capture, tag, block)
    raise UnexpectedStatusError.new("unexpected status: #{status}") \
      unless status == :resume
    f.call()
  end

  module_function :reset_at, :shift_at, :run_at, :prompt0_at, :control0_at
end
