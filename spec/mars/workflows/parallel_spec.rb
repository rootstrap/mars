# frozen_string_literal: true

RSpec.describe MARS::Workflows::Parallel do
  let(:sum_aggregator) { MARS::Aggregator.new("Sum Aggregator", operation: lambda(&:sum)) }

  let(:add_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(value, **kwargs)
        super(**kwargs)
        @value = value
      end

      def run(input)
        sleep 0.1
        input.current_input + @value
      end
    end
  end

  let(:multiply_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(multiplier, **kwargs)
        super(**kwargs)
        @multiplier = multiplier
      end

      def run(input)
        input.current_input * @multiplier
      end
    end
  end

  let(:error_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(message, **kwargs)
        super(**kwargs)
        @message = message
      end

      def run(_input)
        raise StandardError, @message
      end
    end
  end

  describe "#run" do
    it "executes steps in parallel without an aggregator" do
      add_five = add_step_class.new(5, name: "add_five")
      multiply_three = multiply_step_class.new(3, name: "multiply_three")
      add_two = add_step_class.new(2, name: "add_two")

      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two])

      # 10 + 5 = 15, 10 * 3 = 30, 10 + 2 = 12
      expect(workflow.run(10)).to eq([15, 30, 12])
    end

    it "executes steps in parallel with a custom aggregator" do
      add_five = add_step_class.new(5, name: "add_five")
      multiply_three = multiply_step_class.new(3, name: "multiply_three")
      add_two = add_step_class.new(2, name: "add_two")
      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two],
                                                      aggregator: sum_aggregator)

      expect(workflow.run(10)).to eq(57)
    end

    it "handles single step" do
      multiply_step = multiply_step_class.new(7, name: "multiply")
      workflow = described_class.new("single_step", steps: [multiply_step])

      expect(workflow.run(6)).to eq([42])
    end

    it "returns empty array when no steps" do
      workflow = described_class.new("empty", steps: [])

      expect(workflow.run(42)).to eq([])
    end

    it "records outputs in context per step" do
      step1 = Class.new(MARS::Runnable) do
        def run(input) = "from_step1:#{input.current_input}"
      end.new(name: "step1")

      step2 = Class.new(MARS::Runnable) do
        def run(input) = "from_step2:#{input.current_input}"
      end.new(name: "step2")

      context = MARS::ExecutionContext.new(input: "hello")
      workflow = described_class.new("ctx_workflow", steps: [step1, step2])
      workflow.run(context)

      expect(context[:step1]).to eq("from_step1:hello")
      expect(context[:step2]).to eq("from_step2:hello")
    end

    it "forks context so parallel steps get independent current_input" do
      step1 = Class.new(MARS::Runnable) do
        def run(input) = "#{input.current_input}_modified"
      end.new(name: "step1")

      step2 = Class.new(MARS::Runnable) do
        def run(input) = "#{input.current_input}_also_modified"
      end.new(name: "step2")

      context = MARS::ExecutionContext.new(input: "original")
      workflow = described_class.new("fork_test", steps: [step1, step2])
      workflow.run(context)

      # Both steps received the same original input
      expect(context[:step1]).to eq("original_modified")
      expect(context[:step2]).to eq("original_also_modified")
    end

    it "shares global_state across forked contexts" do
      step1 = Class.new(MARS::Runnable) do
        def run(_input)
          "done"
        end
      end.new(name: "step1")

      context = MARS::ExecutionContext.new(input: "test", global_state: { shared: true })
      workflow = described_class.new("shared_state", steps: [step1])
      workflow.run(context)

      expect(context.global_state[:shared]).to be true
    end

    it "calls formatter on each step" do
      uppercase_formatter = Class.new(MARS::Formatter) do
        def format_output(output)
          output.upcase
        end
      end

      step = Class.new(MARS::Runnable) do
        def run(input) = "result:#{input.current_input}"
      end.new(name: "step", formatter: uppercase_formatter.new)

      workflow = described_class.new("fmt_workflow", steps: [step])

      expect(workflow.run("hello")).to eq(["RESULT:HELLO"])
    end

    it "fires before_run and after_run hooks" do
      hook_log = []

      step_class = Class.new(MARS::Runnable) do
        before_run { |_ctx, step| hook_log << "before:#{step.name}" }
        after_run { |_ctx, _result, step| hook_log << "after:#{step.name}" }

        def run(input) = input
      end

      step = step_class.new(name: "hooked")
      workflow = described_class.new("hook_workflow", steps: [step])
      workflow.run("test")

      expect(hook_log).to eq(["before:hooked", "after:hooked"])
    end

    it "unwraps local halts and returns plain result" do
      gate = MARS::Gate.new(
        "local_branch",
        check: ->(_input) { :branch },
        fallbacks: {
          branch: Class.new(MARS::Runnable) do
            def run(input)
              "branched:#{input.current_input}"
            end
          end.new(name: "branch_step")
        }
      )
      add_five = add_step_class.new(5, name: "add_five")

      workflow = described_class.new("halt_workflow", steps: [gate, add_five])

      result = workflow.run(10)
      expect(result).not_to be_a(MARS::Halt)
      expect(result).to eq(["branched:10", 15])
    end

    it "propagates global halt to parent workflow" do
      gate = MARS::Gate.new(
        "global_branch",
        check: ->(_input) { :branch },
        fallbacks: {
          branch: Class.new(MARS::Runnable) do
            def run(input)
              "branched:#{input.current_input}"
            end
          end.new(name: "branch_step")
        },
        halt_scope: :global
      )
      add_five = add_step_class.new(5, name: "add_five")

      workflow = described_class.new("halt_workflow", steps: [gate, add_five])

      result = workflow.run(10)
      expect(result).to be_a(MARS::Halt)
      expect(result).to be_global
      expect(result.result).to eq(["branched:10", 15])
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(5, name: "add")
      error_step = error_step_class.new("Step failed", name: "error_step_one")
      error_step_two = error_step_class.new("Step failed two", name: "error_step_two")

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
