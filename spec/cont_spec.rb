require 'rspec'
require_relative '../lib/cont/single_prompt'

RSpec.describe SinglePrompt do
  describe '.reset' do
    it 'executes the block and returns the result' do
      result = SinglePrompt.reset do
        42
      end
      expect(result).to eq(42)
    end
  end

  describe '.shift' do
    it 'captures and resumes the continuation correctly' do
      result = SinglePrompt.reset do
        SinglePrompt.shift do |cont|
          cont.call(42) + 1
        end
      end
      expect(result).to eq(43)
    end
  end
end

