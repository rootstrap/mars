# frozen_string_literal: true

RSpec.describe Mars::Workflows::Parallel do
  let(:sum_aggregator) { Mars::Aggregator.new("Sum Aggregator", operation: lambda(&:sum)) }
  let(:add_step_class) do
    Class.new do
      def initialize(value)
        @value = value
      end

      def run(input)
        sleep 0.1
        input + @value
      end
    end
  end

  let(:multiply_step_class) do
    Class.new do
      def initialize(multiplier)
        @multiplier = multiplier
      end

      def run(input)
        input * @multiplier
      end
    end
  end

  let(:error_step_class) do
    Class.new do
      attr_reader :name

      def initialize(message, name)
        @message = message
        @name = name
      end

      def run(_input)
        raise StandardError, @message
      end
    end
  end

  describe "#run" do
    it "executes steps in parallel without an aggregator" do
      add_five = add_step_class.new(5)
      multiply_three = multiply_step_class.new(3)
      add_two = add_step_class.new(2)

      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two])

      # 10 + 5 = 15, 10 * 3 = 30, 10 + 2 = 12
      expect(workflow.run(10)).to eq([15, 30, 12])
    end

    it "executes steps in parallel with a custom aggregator" do
      add_five = add_step_class.new(5)
      multiply_three = multiply_step_class.new(3)
      add_two = add_step_class.new(2)
      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two],
                                                      aggregator: sum_aggregator)

      expect(workflow.run(10)).to eq(57)
    end

    it "handles single step" do
      multiply_step = multiply_step_class.new(7)
      workflow = described_class.new("single_step", steps: [multiply_step])

      expect(workflow.run(6)).to eq([42])
    end

    it "returns empty array when no steps" do
      workflow = described_class.new("empty", steps: [])

      expect(workflow.run(42)).to eq([])
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(5)
      error_step = error_step_class.new("Step failed", "error_step_one")
      error_step_two = error_step_class.new("Step failed two", "error_step_two")

      workflow = described_class.new("error_workflow", steps: [add_step, error_step, error_step_two])

      expect { workflow.run(10) }.to raise_error(
        Mars::Workflows::AggregateError,
        "error_step_one: Step failed\nerror_step_two: Step failed two"
      )
    end
  end

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      workflow = described_class.new("test", steps: [])
      expect(workflow).to be_a(Mars::Runnable)
    end
  end
end
