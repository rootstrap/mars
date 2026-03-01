# frozen_string_literal: true

RSpec.describe MARS::Workflows::Parallel do
  let(:add_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(value:, **kwargs)
        super(**kwargs)
        @value = value
      end

      def run(input)
        input + @value
      end
    end
  end

  let(:multiply_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(multiplier:, **kwargs)
        super(**kwargs)
        @multiplier = multiplier
      end

      def run(input)
        input * @multiplier
      end
    end
  end

  let(:error_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(message:, **kwargs)
        super(**kwargs)
        @message = message
      end

      def run(_input)
        raise StandardError, @message
      end
    end
  end

  describe "#run" do
    it "executes steps in parallel and returns context with all outputs" do
      add_five = add_step_class.new(value: 5, name: "add_five")
      multiply_three = multiply_step_class.new(multiplier: 3, name: "multiply_three")
      add_two = add_step_class.new(value: 2, name: "add_two")

      aggregator = MARS::Aggregator.new("sum", operation: ->(ctx) { ctx.values.sum })
      workflow = described_class.new("math_workflow",
                                     steps: [add_five, multiply_three, add_two],
                                     aggregator: aggregator)

      # 10+5=15, 10*3=30, 10+2=12 → sum=57
      result = workflow.run(10)
      expect(result).to eq(57)
    end

    it "records each step output in the merged context" do
      add_five = add_step_class.new(value: 5, name: "add_five")
      multiply_three = multiply_step_class.new(multiplier: 3, name: "multiply_three")

      aggregator = MARS::Aggregator.new("pass", operation: ->(outputs) { outputs })
      workflow = described_class.new("math_workflow",
                                     steps: [add_five, multiply_three],
                                     aggregator: aggregator)

      result = workflow.run(10)
      expect(result).to eq({ add_five: 15, multiply_three: 30 })
    end

    it "each branch gets independent current_input" do
      tracker = Class.new(MARS::Runnable) do
        def run(input)
          "saw:#{input}"
        end
      end

      step_a = tracker.new(name: "a")
      step_b = tracker.new(name: "b")

      aggregator = MARS::Aggregator.new("collect", operation: lambda(&:values))
      workflow = described_class.new("independent", steps: [step_a, step_b], aggregator: aggregator)

      result = workflow.run("original")
      expect(result).to eq(["saw:original", "saw:original"])
    end

    it "shares global_state across branches" do
      writer = Class.new(MARS::Runnable) do
        after_run do |ctx, _result, step|
          ctx.global_state[step.name.to_sym] = true
        end

        def run(input)
          input
        end
      end

      step_a = writer.new(name: "a")
      step_b = writer.new(name: "b")

      aggregator = MARS::Aggregator.new("check", operation: ->(outputs) { outputs })
      workflow = described_class.new("shared_state",
                                     steps: [step_a, step_b],
                                     aggregator: aggregator)

      ctx = MARS::ExecutionContext.new(input: "x", global_state: {})
      workflow.run(ctx)

      expect(ctx.global_state[:a]).to be(true)
      expect(ctx.global_state[:b]).to be(true)
    end

    it "returns empty result when no steps" do
      workflow = described_class.new("empty", steps: [])

      result = workflow.run(42)
      expect(result).to eq({})
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(value: 5, name: "add")
      error_step = error_step_class.new(message: "Step failed", name: "error_step_one")
      error_step_two = error_step_class.new(message: "Step failed two", name: "error_step_two")

      workflow = described_class.new("error_workflow", steps: [add_step, error_step, error_step_two])

      expect { workflow.run(10) }.to raise_error(
        MARS::Workflows::AggregateError,
        "error_step_one: Step failed\nerror_step_two: Step failed two"
      )
    end
  end

  describe "inheritance" do
    it "inherits from MARS::Runnable" do
      workflow = described_class.new("test", steps: [])
      expect(workflow).to be_a(MARS::Runnable)
    end
  end
end
