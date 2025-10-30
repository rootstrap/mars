# frozen_string_literal: true

RSpec.describe Mars::Aggregator do
  describe "#run" do
    let(:aggregator) { described_class.new }

    context "when called without a block" do
      it "joins inputs with newlines" do
        inputs = %w[first second third]
        result = aggregator.run(inputs)
        expect(result).to eq("first\nsecond\nthird")
      end

      it "handles empty array" do
        result = aggregator.run([])
        expect(result).to eq("")
      end

      it "handles single input" do
        result = aggregator.run(["single"])
        expect(result).to eq("single")
      end

      it "handles numeric inputs" do
        inputs = [1, 2, 3]
        result = aggregator.run(inputs)
        expect(result).to eq("1\n2\n3")
      end
    end

    context "when called with a block" do
      it "executes the block and returns its value" do
        result = aggregator.run(["ignored"]) { "block result" }
        expect(result).to eq("block result")
      end

      it "ignores the inputs when block is given" do
        inputs = %w[first second]
        result = aggregator.run(inputs) { "custom aggregation" }
        expect(result).to eq("custom aggregation")
      end

      it "can perform custom aggregation logic" do
        inputs = [1, 2, 3, 4, 5]
        result = aggregator.run(inputs) { inputs.sum }
        expect(result).to eq(15)
      end
    end
  end
end
