# frozen_string_literal: true

RSpec.describe MARS::Workflows::Parallel do
  let(:sum_aggregator) do
    MARS::Aggregator.new("Sum Aggregator", operation: lambda { |results, _ctx| MARS::Result.new(value: results.sum(&:value)) })
  end

  let(:add_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(value, **kwargs)
        super(**kwargs)
        @value = value
      end

      def run(input, ctx: {})
        sleep 0.1
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
    it "executes steps in parallel without an aggregator" do
      add_five = add_step_class.new(5, name: "add_five")
      multiply_three = multiply_step_class.new(3, name: "multiply_three")
      add_two = add_step_class.new(2, name: "add_two")

      workflow = described_class.new(
        "math_workflow",
        steps: [add_five, multiply_three, add_two]
      )

      # 10 + 5 = 15, 10 * 3 = 30, 10 + 2 = 12
      expect(workflow.run(10).value).to eq(
        [
          MARS::Result.new(value: 15),
          MARS::Result.new(value: 30),
          MARS::Result.new(value: 12)
        ]
      )
    end

    it "executes steps in parallel with a custom aggregator" do
      add_five = add_step_class.new(5, name: "add_five")
      multiply_three = multiply_step_class.new(3, name: "multiply_three")
      add_two = add_step_class.new(2, name: "add_two")
      workflow = described_class.new(
        "math_workflow",
        steps: [add_five, multiply_three, add_two],
        aggregator: sum_aggregator
      )

      expect(workflow.run(10).value).to eq(57)
    end

    it "handles single step" do
      multiply_step = multiply_step_class.new(7, name: "multiply")
      workflow = described_class.new("single_step", steps: [multiply_step])

      expect(workflow.run(6).value).to eq([MARS::Result.new(value: 42)])
    end

    it "returns empty array when no steps" do
      workflow = described_class.new("empty", steps: [])

      expect(workflow.run(42).value).to eq([])
    end

    it "records outputs in context per step" do
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
      expect(context[:step2]).to eq(MARS::Result.new(value: "from_step2:hello"))
      expect(result.outputs[:step1]).to eq(MARS::Result.new(value: "from_step1:hello"))
    end

    it "forks context so parallel steps get independent current_input" do
      step1 = Class.new(MARS::Step) do
        def run(input, ctx: {}) = MARS::Result.new(value: "#{input.value}_modified")
      end.new(name: "step1")

      step2 = Class.new(MARS::Step) do
        def run(input, ctx: {}) = MARS::Result.new(value: "#{input.value}_also_modified")
      end.new(name: "step2")

      context = MARS::Context.new(input: "original")
      workflow = described_class.new("fork_test", steps: [step1, step2])
      workflow.run(context)

      # Both steps received the same original input
      expect(context[:step1]).to eq(MARS::Result.new(value: "original_modified"))
      expect(context[:step2]).to eq(MARS::Result.new(value: "original_also_modified"))
    end

    it "shares global_state across forked contexts" do
      step1 = Class.new(MARS::Step) do
        def run(_input, ctx: {})
          MARS::Result.new(value: "done")
        end
      end.new(name: "step1")

      context = MARS::Context.new(input: "test", global_state: { shared: true })
      workflow = described_class.new("shared_state", steps: [step1])
      workflow.run(context)

      expect(context.state[:shared]).to be true
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

      expect(workflow.run("hello").value).to eq([MARS::Result.new(value: "RESULT:HELLO")])
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

    it "returns branch results when a nested gate stops inside one branch" do
      gate = MARS::Gate.new(
        "branch_gate",
        check: ->(_input, _ctx) { :branch },
        branches: {
          branch: Class.new(MARS::Step) do
            def run(input, ctx: {})
              MARS::Result.new(value: "branched:#{input.value}")
            end
          end.new(name: "branch_step")
        }
      )
      add_five = add_step_class.new(5, name: "add_five")

      workflow = described_class.new(
        "halt_workflow",
        steps: [gate, add_five]
      )

      result = workflow.run(10)
      expect(result.value).to eq(
        [
          MARS::Result.new(value: "branched:10", stopped: true),
          MARS::Result.new(value: 15)
        ]
      )
      expect(result).not_to be_stopped
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(5, name: "add")
      error_step = error_step_class.new("Step failed", name: "error_step_one")
      error_step_two = error_step_class.new("Step failed two", name: "error_step_two")

      workflow = described_class.new(
        "error_workflow",
        steps: [add_step, error_step, error_step_two]
      )

      expect { workflow.run(10) }.to raise_error(
        MARS::Workflows::AggregateError,
        "error_step_one: Step failed\nerror_step_two: Step failed two"
      )
    end
  end

  describe "inheritance" do
    it "inherits from MARS::Runnable" do
      workflow = described_class.new("test", steps: [])
      expect(workflow).to be_a(MARS::Step)
    end
  end
end
