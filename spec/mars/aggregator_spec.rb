# frozen_string_literal: true

RSpec.describe Mars::Aggregator do
  describe "#run" do
    context "when called without a block" do
      let(:aggregator) { described_class.new }

      it "joins inputs with newlines" do
        inputs = %w[first second third]
        result = aggregator.run(inputs)
        expect(result).to eq("first\nsecond\nthird")
      end

      it "handles empty array" do
        result = aggregator.run([])
        expect(result).to eq("")
      end
    end

    context "when initialized with a block operation" do
      let(:aggregator) { described_class.new("Aggregator", operation: lambda(&:join)) }

      it "executes the block and returns its value" do
        result = aggregator.run(%w[a b c])
        expect(result).to eq("abc")
      end
    end
  end
end
