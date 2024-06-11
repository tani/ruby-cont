require 'minitest/autorun'
require_relative '../lib/cont'

describe Cont do
  describe 'reset and shift operations' do
    it 'resets and shifts correctly' do
      result = Cont.reset do
        3 * Cont.shift do |k|
          1 + k.call(5)
        end
      end
      _(result).must_equal 16
    end

    it 'handles nested shift operations within reset block' do
      result = Cont.reset do
        1 + Cont.shift do |k|
          2 * Cont.shift do |l|
            k.call(l.call(5))
          end
        end
      end
      _(result).must_equal 11
    end

    it 'shift returns its continuation' do
      result = Cont.reset do
        f = Cont.shift { |k| k }
        3 * f.call()
      end
      _(result.call(lambda { 7 })).must_equal 21
    end

    it 'nested shift and reset with inner lambda' do
      result = Cont.reset do
        f = Cont.shift { |k| k }
        3 * f.call()
      end
      _(result.call(lambda { Cont.shift { |l| 4 } })).must_equal 4
    end

    it 'calls inner continuation correctly' do
      result = Cont.reset do
        f = Cont.shift { |k| k }
        3 * f.call()
      end
      _(result.call(lambda { Cont.shift { |l| l.call(4) } })).must_equal 12
    end
  end

  describe 'error handling within reset block' do
    def pcall(&block)
      begin
        return true, block.call()
      rescue => e
        return false, e
      end
    end

    it 'raises error within reset block and catches it' do
      status, result = pcall do
        Cont.reset do
          raise 'error'
        end
      end
      _(status).must_equal false
      _(result).must_be_instance_of RuntimeError
    end

    it 'handles exception within reset block and continues correctly' do
      k = Cont.reset do
        status, a = pcall do
          f = Cont.shift { |k| k }
          3 * f.call()
        end
        if status
          a
        else
          puts "Caught exception: #{a}"
          g = Cont.shift { |k| k }
          7 * g.call()
        end
      end
      _(k.call(lambda { Cont.shift { |l| 4 } })).must_equal 4
    end

    it 'handles continuation correctly after catching exception' do
      k = Cont.reset do
        status, a = pcall do
          f = Cont.shift { |k| k }
          3 * f.call()
        end
        if status
          a
        else
          puts "Caught exception: #{a}"
          g = Cont.shift { |k| k }
          7 * g.call()
        end
      end
      _(k.call(lambda { Cont.shift { |l| l.call(4) } })).must_equal 12
    end

    it 'returns proc when exception raised within lambda' do
      k = Cont.reset do
        status, a = pcall do
          f = Cont.shift { |k| k }
          3 * f.call()
        end
        if status
          a
        else
          puts "Caught exception: #{a}"
          g = Cont.shift { |k| k }
          7 * g.call()
        end
      end
      _(k.call(lambda { raise 'error' })).must_be_instance_of Proc
    end
  end

  describe 'multiple resets and shifts' do
    it 'handles multiple resets and shifts' do
      k = Cont.reset_at(:x) do
        1 + Cont.reset_at(:y) do
          3 * Cont.shift_at(:x) { |k| k }
        end
      end
      _(k.call(5)).must_equal 16
    end

    it 'handles nested reset_at and shift_at' do
      k = Cont.reset_at(:x) do
        1 + (Cont.reset_at(:y) do
          a = Cont.shift_at(:x) { |k| k }
          _(a).must_equal 5
          b = Cont.shift_at(:y) { |k| k }
          _(b).must_equal 3
          a * b
        end).call(3)
      end
      _(k.call(5)).must_equal 16
    end
  end

  describe 'control0_at with nested shifts' do
    it 'handles control0_at with nested shifts' do
      result = Cont.reset_at(:x) do
        1 + Cont.reset_at(:y) do
          2 + Cont.control0_at(:x) do |k|
            Cont.run_at(nil, k, :resume, lambda {
              Cont.control0_at(:y) do |l|
                3 * Cont.run_at(nil, l, :resume, lambda { 5 })
              end
            })
          end
        end
      end
      _(result).must_equal 22
    end

    it 'handles control0_at with multiple resets' do
      result = Cont.reset_at(:y) do
        7 * Cont.reset_at(:x) do
          2 + Cont.control0_at(:x) do |k|
            Cont.run_at(nil, k, :resume, lambda {
              Cont.control0_at(:y) do |l|
                3 + Cont.run_at(nil, l, :resume, lambda { 5 })
              end
            })
          end
        end
      end
      _(result).must_equal 52
    end
  end
end
