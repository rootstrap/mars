# frozen_string_literal: true

RSpec.describe MARS::Workflows::Sequential do
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

    it "halts locally when a gate triggers with local scope" do
      add_five = add_step_class.new(5)
      gate = MARS::Gate.new(
        "LocalGate",
        check: ->(_input) { :branch },
        fallbacks: {
          branch: Class.new(MARS::Runnable) do
            def run(input)
              "branched:#{input}"
            end
          end.new
        }
      )
      multiply_three = multiply_step_class.new(3)

      workflow = described_class.new("halt_workflow", steps: [add_five, gate, multiply_three])

      # 10 + 5 = 15, gate branches -> "branched:15", multiply_three is never reached
      # Local halt is consumed — returns plain value
      result = workflow.run(10)
      expect(result).to eq("branched:15")
      expect(result).not_to be_a(MARS::Halt)
    end

    it "propagates global halt without unwrapping" do
      add_five = add_step_class.new(5)
      gate = MARS::Gate.new(
        "GlobalGate",
        check: ->(_input) { :branch },
        fallbacks: {
          branch: Class.new(MARS::Runnable) do
            def run(input)
              "branched:#{input}"
            end
          end.new
        },
        halt_scope: :global
      )
      multiply_three = multiply_step_class.new(3)

      workflow = described_class.new("halt_workflow", steps: [add_five, gate, multiply_three])

      result = workflow.run(10)
      expect(result).to be_a(MARS::Halt)
      expect(result).to be_global
      expect(result.result).to eq("branched:15")
    end

    it "propagates global halt through nested sequential workflows" do
      inner_gate = MARS::Gate.new(
        "InnerGate",
        check: ->(_input) { :stop },
        fallbacks: {
          stop: Class.new(MARS::Runnable) do
            def run(input)
              "stopped:#{input}"
            end
          end.new
        },
        halt_scope: :global
      )

      inner = described_class.new("inner", steps: [inner_gate])
      after_inner = add_step_class.new(100)
      outer = described_class.new("outer", steps: [inner, after_inner])

      result = outer.run(1)
      # Global halt propagates through both sequential levels
      expect(result).to be_a(MARS::Halt)
      expect(result.result).to eq("stopped:1")
    end

    it "consumes local halt — outer workflow continues" do
      inner_gate = MARS::Gate.new(
        "InnerGate",
        check: ->(_input) { :stop },
        fallbacks: {
          stop: Class.new(MARS::Runnable) do
            def run(input)
              "stopped:#{input}"
            end
          end.new
        }
        # default :local scope
      )

      inner = described_class.new("inner", steps: [inner_gate])

      # Inner halts locally -> returns "stopped:1" as plain value
      string_step = Class.new(MARS::Runnable) do
        def run(input)
          "after:#{input}"
        end
      end.new

      outer = described_class.new("outer", steps: [inner, string_step])

      result = outer.run(1)
      expect(result).to eq("after:stopped:1")
      expect(result).not_to be_a(MARS::Halt)
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(5)
      error_step = error_step_class.new("Step failed")

      workflow = described_class.new("error_workflow", steps: [add_step, error_step])

      expect { workflow.run(10) }.to raise_error(StandardError, "Step failed")
    end
  end

  describe "inheritance" do
    it "inherits from MARS::Runnable" do
      workflow = described_class.new("test", steps: [])
      expect(workflow).to be_a(MARS::Runnable)
    end
  end
end
