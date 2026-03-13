# frozen_string_literal: true

RSpec.describe MARS::Context do
  describe "#current_input" do
    it "returns the initial input" do
      context = described_class.new(input: "query")
      expect(context.current_input).to eq(MARS::Result.new(value: "query"))
    end

    it "wraps nil when no input is provided" do
      context = described_class.new
      expect(context.current_input).to eq(MARS::Result.new(value: nil))
    end
  end

  describe "#record" do
    it "stores the output under the step name" do
      context = described_class.new(input: "query")
      context.record(:researcher, "research result")

      expect(context[:researcher]).to eq(MARS::Result.new(value: "research result"))
    end

    it "updates current_input to the recorded output" do
      context = described_class.new(input: "query")
      context.record(:researcher, "research result")

      expect(context.current_input).to eq(MARS::Result.new(value: "research result"))
    end

    it "tracks multiple step outputs" do
      context = described_class.new(input: "query")
      context.record(:researcher, "research result")
      context.record(:summarizer, "summary")

      expect(context.outputs).to eq(
        {
          researcher: MARS::Result.new(value: "research result"),
          summarizer: MARS::Result.new(value: "summary")
        }
      )
      expect(context.current_input).to eq(MARS::Result.new(value: "summary"))
    end
  end

  describe "#[]" do
    it "returns nil for unknown step names" do
      context = described_class.new(input: "query")
      expect(context[:unknown]).to be_nil
    end
  end

  describe "#global_state" do
    it "defaults to an empty hash" do
      context = described_class.new(input: "query")
      expect(context.state).to eq({})
    end

    it "accepts initial global state" do
      context = described_class.new(input: "query", global_state: { user_id: 42 })
      expect(context.state).to eq({ user_id: 42 })
    end

    it "is mutable" do
      context = described_class.new(input: "query")
      context.state[:key] = "value"

      expect(context.state[:key]).to eq("value")
    end
  end

  describe "#fork" do
    it "creates a child context with the same current_input by default" do
      context = described_class.new(input: "query")
      child = context.fork

      expect(child.current_input).to eq(MARS::Result.new(value: "query"))
    end

    it "creates a child context with a custom input" do
      context = described_class.new(input: "query")
      child = context.fork(input: "custom")

      expect(child.current_input).to eq(MARS::Result.new(value: "custom"))
    end

    it "shares global_state with the parent" do
      context = described_class.new(input: "query", global_state: { shared: true })
      child = context.fork

      child.state[:added_by_child] = true

      expect(context.state[:added_by_child]).to be(true)
    end

    it "has independent outputs from the parent" do
      context = described_class.new(input: "query")
      context.record(:parent_step, "parent output")

      child = context.fork
      child.record(:child_step, "child output")

      expect(context[:child_step]).to be_nil
      expect(child[:parent_step]).to be_nil
    end
  end

  describe "#merge" do
    it "merges child outputs into the parent" do
      context = described_class.new(input: "query")
      context.record(:step1, "output1")

      child1 = context.fork
      child1.record(:branch_a, "result_a")

      child2 = context.fork
      child2.record(:branch_b, "result_b")

      context.merge([child1, child2])

      expect(context[:step1]).to eq(MARS::Result.new(value: "output1"))
      expect(context[:branch_a]).to eq(MARS::Result.new(value: "result_a"))
      expect(context[:branch_b]).to eq(MARS::Result.new(value: "result_b"))
    end
  end

  describe "#fetch" do
    it "fetches a stored output by step name" do
      context = described_class.new(input: "query")
      context.record(:researcher, "research result")

      expect(context.fetch(:researcher)).to eq(MARS::Result.new(value: "research result"))
    end
  end

  describe "#stop!" do
    it "raises an internal stop signal with the provided value" do
      context = described_class.new(input: "query")

      expect { context.stop!("done") }
        .to raise_error(MARS::Context::Stop) do |error|
          expect(error.result).to eq(MARS::Result.new(value: "done", stopped: true))
        end
    end
  end
end
