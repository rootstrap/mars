# frozen_string_literal: true

RSpec.describe Mars::Workflows::Sequential do
  let(:add_step_class) do
    Class.new do
      def initialize(value)
        @value = value
      end

      def run(input)
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
      def initialize(message)
        @message = message
      end

      def run(_input)
        raise StandardError, @message
      end
    end
  end

  describe "#run" do
    it "executes steps sequentially" do
      add_five = add_step_class.new(5)
      multiply_three = multiply_step_class.new(3)
      add_two = add_step_class.new(2)

      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two])

      # 10 + 5 = 15, 15 * 3 = 45, 45 + 2 = 47
      expect(workflow.run(10)).to eq(47)
    end

    it "handles single step" do
      multiply_step = multiply_step_class.new(7)
      workflow = described_class.new("single_step", steps: [multiply_step])

      expect(workflow.run(6)).to eq(42)
    end

    it "returns input unchanged when no steps" do
      workflow = described_class.new("empty", steps: [])

      expect(workflow.run(42)).to eq(42)
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(5)
      error_step = error_step_class.new("Step failed")

      workflow = described_class.new("error_workflow", steps: [add_step, error_step])

      expect { workflow.run(10) }.to raise_error(StandardError, "Step failed")
    end
  end

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      workflow = described_class.new("test", steps: [])
      expect(workflow).to be_a(Mars::Runnable)
    end
  end
end
