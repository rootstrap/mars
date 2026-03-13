# frozen_string_literal: true

RSpec.describe MARS::Workflows::Sequential do
  let(:add_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(value, **kwargs)
        super(**kwargs)
        @value = value
      end

      def run(input, ctx: {})
        MARS::Result.new(value: input.value + @value)
      end
    end
  end

  let(:multiply_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(multiplier, **kwargs)
        super(**kwargs)
        @multiplier = multiplier
      end

      def run(input, ctx: {})
        MARS::Result.new(value: input.value * @multiplier)
      end
    end
  end

  let(:error_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(message, **kwargs)
        super(**kwargs)
        @message = message
      end

      def run(_input, ctx: {})
        raise StandardError, @message
      end
    end
  end

  describe "#run" do
    it "executes steps sequentially" do
      add_five = add_step_class.new(5, name: "add_five")
      multiply_three = multiply_step_class.new(3, name: "multiply_three")
      add_two = add_step_class.new(2, name: "add_two")

      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two])

      # 10 + 5 = 15, 15 * 3 = 45, 45 + 2 = 47
      result = workflow.run(10)
      expect(result.value).to eq(47)
      expect(result).not_to be_stopped
    end

    it "handles single step" do
      multiply_step = multiply_step_class.new(7, name: "multiply")
      workflow = described_class.new("single_step", steps: [multiply_step])

      expect(workflow.run(6).value).to eq(42)
    end

    it "returns input unchanged when no steps" do
      workflow = described_class.new("empty", steps: [])

      expect(workflow.run(42).value).to eq(42)
    end

    it "records outputs in context accessible by step name" do
      step1 = Class.new(MARS::Step) do
        def run(input, ctx: {}) = MARS::Result.new(value: "from_step1:#{input.value}")
      end.new(name: "step1")

      step2 = Class.new(MARS::Step) do
        def run(input, ctx: {}) = MARS::Result.new(value: "from_step2:#{input.value}")
      end.new(name: "step2")

      context = MARS::Context.new(input: "hello")
      workflow = described_class.new("ctx_workflow", steps: [step1, step2])
      result = workflow.run(context)

      expect(context[:step1]).to eq(MARS::Result.new(value: "from_step1:hello"))
      expect(context[:step2]).to eq(MARS::Result.new(value: "from_step2:from_step1:hello"))
      expect(result.outputs[:step2]).to eq(MARS::Result.new(value: "from_step2:from_step1:hello"))
    end

    it "wraps raw input in Context automatically" do
      step = Class.new(MARS::Step) do
        def run(input, ctx: {}) = MARS::Result.new(value: "processed:#{input.value}")
      end.new(name: "step")

      workflow = described_class.new("auto_wrap", steps: [step])

      expect(workflow.run("raw").value).to eq("processed:raw")
    end

    it "calls formatter on each step" do
      uppercase_formatter = Class.new(MARS::Formatter) do
        def format_output(output)
          MARS::Result.new(value: output.value.upcase, stopped: output.stopped?)
        end
      end

      step = Class.new(MARS::Step) do
        def run(input, ctx: {}) = MARS::Result.new(value: "result:#{input.value}")
      end.new(name: "step", formatter: uppercase_formatter.new)

      workflow = described_class.new("fmt_workflow", steps: [step])

      expect(workflow.run("hello").value).to eq("RESULT:HELLO")
    end

    it "fires before_run and after_run hooks" do
      hook_log = []

      step_class = Class.new(MARS::Step) do
        before_run { |_ctx, step| hook_log << "before:#{step.name}" }
        after_run { |_ctx, _result, step| hook_log << "after:#{step.name}" }

        def run(input, ctx: {}) = input
      end

      step = step_class.new(name: "hooked")
      workflow = described_class.new("hook_workflow", steps: [step])
      workflow.run("test")

      expect(hook_log).to eq(["before:hooked", "after:hooked"])
    end

    it "stops the current workflow when a gate triggers" do
      add_five = add_step_class.new(5, name: "add_five")
      gate = MARS::Gate.new(
        "gate",
        check: ->(_input, _ctx) { :branch },
        branches: {
          branch: Class.new(MARS::Step) do
            def run(input, ctx: {})
              MARS::Result.new(value: "branched:#{input.value}")
            end
          end.new(name: "branch_step")
        }
      )
      multiply_three = multiply_step_class.new(3, name: "multiply_three")

      workflow = described_class.new("halt_workflow", steps: [add_five, gate, multiply_three])

      # 10 + 5 = 15, gate branches -> "branched:15", multiply_three is never reached
      result = workflow.run(10)
      expect(result).to be_stopped
      expect(result.value).to eq("branched:15")
    end

    it "consumes local halt — outer workflow continues" do
      inner_gate = MARS::Gate.new(
        "inner_gate",
        check: ->(_input, _ctx) { :stop },
        branches: {
          stop: Class.new(MARS::Step) do
            def run(input, ctx: {})
              MARS::Result.new(value: "stopped:#{input.value}")
            end
          end.new(name: "stop_step")
        }
      )

      inner = described_class.new("inner", steps: [inner_gate])

      string_step = Class.new(MARS::Step) do
        def run(input, ctx: {})
          MARS::Result.new(value: "after:#{input.value}")
        end
      end.new(name: "after_step")

      outer = described_class.new("outer", steps: [inner, string_step])

      result = outer.run(1)
      expect(result.value).to eq("after:stopped:1")
      expect(result).not_to be_stopped
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(5, name: "add")
      error_step = error_step_class.new("Step failed", name: "error")

      workflow = described_class.new("error_workflow", steps: [add_step, error_step])

      expect { workflow.run(10) }.to raise_error(StandardError, "Step failed")
    end
  end

  describe "inheritance" do
    it "inherits from MARS::Runnable" do
      workflow = described_class.new("test", steps: [])
      expect(workflow).to be_a(MARS::Step)
    end
  end
end
