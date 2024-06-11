require 'rspec'
require_relative '../lib/cont'

RSpec.describe Cont do
  describe 'SinglePrompt' do
    it 'computes the correct result after reset and shift operations' do
      result = Cont.reset do
        3 * Cont.shift do |k|
          1 + k.call(5)
        end
      end
      expect(result).to eq(16)
    end

    it 'computes the correct result with nested shift operations within a reset block' do
      result = Cont.reset do
        1 + Cont.shift do |k|
          2 * Cont.shift do |l|
            k.call(l.call(5))
          end
        end
      end
      expect(result).to eq(11)
    end

    it 'returns the correct result when shift returns its continuation' do
      result = Cont.reset do
        f = Cont.shift { |k| k }
        3 * f.call()
      end
      expect(result.call(lambda { 7 })).to eq(21)
    end

    it 'handles nested shift and reset correctly with an inner lambda' do
      result = Cont.reset do
        f = Cont.shift { |k| k }
        3 * f.call()
      end
      expect(result.call(lambda { Cont.shift { |l| 4 } })).to eq(4)
    end

    it 'calls inner continuation correctly' do
      result = Cont.reset do
        f = Cont.shift { |k| k }
        3 * f.call()
      end
      expect(result.call(lambda { Cont.shift { |l| l.call(4) } })).to eq(12)
    end

    def pcall(&block)
      begin
        return true, block.call()
      rescue => e
        return false, e
      end
    end

    it 'raises an error within a reset block and catches it' do
      status, result = pcall do
        Cont.reset do
          raise 'error'
        end
      end
      expect(status).to eq(false)
      expect(result).to be_a(RuntimeError)
    end

    it 'handles an exception within a reset block and continues correctly' do
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
      expect(k.call(lambda { Cont.shift { |l| 4 }})).to eq(4)
    end

    it 'handles continuation correctly after catching an exception' do
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
      expect(k.call(lambda { Cont.shift { |l| l.call(4) }})).to eq(12)
    end

    it 'returns a proc when an exception is raised within a lambda' do
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
      expect(k.call(lambda { raise 'error' })).to be_a(Proc)
    end
  end

  describe 'MultiPrompt' do
    it 'computes the correct result with multiple resets and shifts' do
      k = Cont.reset_at(:x) do
        1 + Cont.reset_at(:y) do
          3 * Cont.shift_at(:x) { |k| k }
        end
      end
      expect(k.call(5)).to eq(16)
    end
  end

  it 'computes the correct result with nested reset_at and shift_at' do
    k = Cont.reset_at(:x) do
      1 + (Cont.reset_at(:y) do
        a = Cont.shift_at(:x) { |k| k }
        expect(a).to eq(5)
        b = Cont.shift_at(:y) { |k| k }
        expect(b).to eq(3)
        a * b
      end).call(3)
    end
    expect(k.call(5)).to eq(16)
  end

  it 'computes the correct result with control0_at' do
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
    expect(result).to eq(22)
  end

  it 'computes the correct result with control0_at' do
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
    expect(result).to eq(52)
  end
end
