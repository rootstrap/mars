# frozen_string_literal: true

RSpec.describe Mars::Aggregator do
  describe "#initialize" do
    it "initializes with a default name" do
      aggregator = described_class.new
      expect(aggregator.name).to eq("Aggregator")
    end

    it "initializes with a custom name" do
      aggregator = described_class.new("CustomAggregator")
      expect(aggregator.name).to eq("CustomAggregator")
    end
  end

  describe "#name" do
    it "returns the aggregator name" do
      aggregator = described_class.new("MyAggregator")
      expect(aggregator.name).to eq("MyAggregator")
    end
  end

  describe "#run" do
    let(:aggregator) { described_class.new }

    context "when called without a block" do
      it "joins inputs with newlines" do
        inputs = ["first", "second", "third"]
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
        inputs = ["first", "second"]
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

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      expect(described_class.ancestors).to include(Mars::Runnable)
    end
  end
end
