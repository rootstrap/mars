# frozen_string_literal: true

RSpec.describe Mars::Aggregator do
  describe "#run" do
    context "when called without a block" do
      let(:aggregator) { described_class.new }

      it "returns the input as is" do
        result = aggregator.run([1, 2, 3])
        expect(result).to eq([1, 2, 3])
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
