require 'rspec'
require_relative '../lib/cont'

RSpec.describe Cont do
  describe '.reset' do
    it 'executes the block and returns the result' do
      result = Cont.reset do
        42
      end
      expect(result).to eq(42)
    end
  end

  describe '.shift' do
    it 'captures and resumes the continuation correctly' do
      result = Cont.reset do
        Cont.shift do |cont|
          cont.call(42) + 1
        end
      end
      expect(result).to eq(43)
    end
  end
end

