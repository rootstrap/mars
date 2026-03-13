# frozen_string_literal: true

RSpec.describe MARS::Aggregator do
  describe "#run" do
    context "when called without an operation" do
      let(:aggregator) { described_class.new }

      it "returns the input as is" do
        inputs = [MARS::Result.new(value: 1), MARS::Result.new(value: 2), MARS::Result.new(value: 3)]
        result = aggregator.run(inputs)
        expect(result).to eq(MARS::Result.new(value: inputs))
      end
    end

    context "when initialized with an operation" do
      let(:aggregator) do
        described_class.new("Aggregator", operation: lambda { |results, _ctx| results.map(&:value).join })
      end

      it "executes the operation and returns its value" do
        result = aggregator.run([MARS::Result.new(value: "a"), MARS::Result.new(value: "b"), MARS::Result.new(value: "c")])
        expect(result).to eq(MARS::Result.new(value: "abc"))
      end
    end
  end
end
