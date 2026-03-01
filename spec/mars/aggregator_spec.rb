# frozen_string_literal: true

RSpec.describe MARS::Aggregator do
  describe "#run" do
    context "when called without an operation" do
      let(:aggregator) { described_class.new }

      it "returns the input as is" do
        result = aggregator.run([1, 2, 3])
        expect(result).to eq([1, 2, 3])
      end
    end

    context "when initialized with an operation" do
      let(:aggregator) { described_class.new("Aggregator", operation: lambda(&:join)) }

      it "executes the operation and returns its value" do
        result = aggregator.run(%w[a b c])
        expect(result).to eq("abc")
      end
    end

    context "when given an ExecutionContext" do
      let(:aggregator) do
        described_class.new("ContextAggregator", operation: ->(outputs) { outputs.values.join(", ") })
      end

      it "passes the context outputs to the operation" do
        context = MARS::ExecutionContext.new(input: "query")
        context.record(:step_a, "result_a")
        context.record(:step_b, "result_b")

        result = aggregator.run(context)
        expect(result).to eq("result_a, result_b")
      end
    end
  end
end
