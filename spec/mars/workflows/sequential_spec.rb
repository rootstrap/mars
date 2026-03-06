# frozen_string_literal: true

RSpec.describe MARS::Workflows::Sequential do
  let(:add_step_class) do
    Class.new(MARS::Runnable) do
      def initialize(value, **kwargs)
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
      def initialize(multiplier, **kwargs)
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
    it "executes steps sequentially" do
      add_five = add_step_class.new(5, name: "add_five")
      multiply_three = multiply_step_class.new(3, name: "multiply_three")
      add_two = add_step_class.new(2, name: "add_two")

      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two])

      # 10 + 5 = 15, 15 * 3 = 45, 45 + 2 = 47
      expect(workflow.run(10)).to eq(47)
    end

    it "handles single step" do
      multiply_step = multiply_step_class.new(7, name: "multiply")
      workflow = described_class.new("single_step", steps: [multiply_step])

      expect(workflow.run(6)).to eq(42)
    end

    it "returns input unchanged when no steps" do
      workflow = described_class.new("empty", steps: [])

      expect(workflow.run(42)).to eq(42)
    end

    it "records outputs in context accessible by step name" do
      step1 = Class.new(MARS::Runnable) do
        def run(input) = "from_step1:#{input}"
      end.new(name: "step1")

      step2 = Class.new(MARS::Runnable) do
        def run(input) = "from_step2:#{input}"
      end.new(name: "step2")

      context = MARS::ExecutionContext.new(input: "hello")
      workflow = described_class.new("ctx_workflow", steps: [step1, step2])
      workflow.run(context)

      expect(context[:step1]).to eq("from_step1:hello")
      expect(context[:step2]).to eq("from_step2:from_step1:hello")
    end

    it "wraps raw input in ExecutionContext automatically" do
      step = Class.new(MARS::Runnable) do
        def run(input) = "processed:#{input}"
      end.new(name: "step")

      workflow = described_class.new("auto_wrap", steps: [step])

      expect(workflow.run("raw")).to eq("processed:raw")
    end

    it "calls formatter on each step" do
      uppercase_formatter = Class.new(MARS::Formatter) do
        def format_output(output)
          output.upcase
        end
      end

      step = Class.new(MARS::Runnable) do
        def run(input) = "result:#{input}"
      end.new(name: "step", formatter: uppercase_formatter.new)

      workflow = described_class.new("fmt_workflow", steps: [step])

      expect(workflow.run("hello")).to eq("RESULT:HELLO")
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

    it "halts locally when a gate triggers with local scope" do
      add_five = add_step_class.new(5, name: "add_five")
      gate = MARS::Gate.new(
        "local_gate",
        check: ->(_input) { :branch },
        fallbacks: {
          branch: Class.new(MARS::Runnable) do
            def run(input)
              "branched:#{input}"
            end
          end.new(name: "branch_step")
        }
      )
      multiply_three = multiply_step_class.new(3, name: "multiply_three")

      workflow = described_class.new("halt_workflow", steps: [add_five, gate, multiply_three])

      # 10 + 5 = 15, gate branches -> "branched:15", multiply_three is never reached
      result = workflow.run(10)
      expect(result).to eq("branched:15")
      expect(result).not_to be_a(MARS::Halt)
    end

    it "propagates global halt without unwrapping" do
      add_five = add_step_class.new(5, name: "add_five")
      gate = MARS::Gate.new(
        "global_gate",
        check: ->(_input) { :branch },
        fallbacks: {
          branch: Class.new(MARS::Runnable) do
            def run(input)
              "branched:#{input}"
            end
          end.new(name: "branch_step")
        },
        halt_scope: :global
      )
      multiply_three = multiply_step_class.new(3, name: "multiply_three")

      workflow = described_class.new("halt_workflow", steps: [add_five, gate, multiply_three])

      result = workflow.run(10)
      expect(result).to be_a(MARS::Halt)
      expect(result).to be_global
      expect(result.result).to eq("branched:15")
    end

    it "propagates global halt through nested sequential workflows" do
      inner_gate = MARS::Gate.new(
        "inner_gate",
        check: ->(_input) { :stop },
        fallbacks: {
          stop: Class.new(MARS::Runnable) do
            def run(input)
              "stopped:#{input}"
            end
          end.new(name: "stop_step")
        },
        halt_scope: :global
      )

      inner = described_class.new("inner", steps: [inner_gate])
      after_inner = add_step_class.new(100, name: "after_inner")
      outer = described_class.new("outer", steps: [inner, after_inner])

      result = outer.run(1)
      expect(result).to be_a(MARS::Halt)
      expect(result.result).to eq("stopped:1")
    end

    it "consumes local halt — outer workflow continues" do
      inner_gate = MARS::Gate.new(
        "inner_gate",
        check: ->(_input) { :stop },
        fallbacks: {
          stop: Class.new(MARS::Runnable) do
            def run(input)
              "stopped:#{input}"
            end
          end.new(name: "stop_step")
        }
      )

      inner = described_class.new("inner", steps: [inner_gate])

      string_step = Class.new(MARS::Runnable) do
        def run(input)
          "after:#{input}"
        end
      end.new(name: "after_step")

      outer = described_class.new("outer", steps: [inner, string_step])

      result = outer.run(1)
      expect(result).to eq("after:stopped:1")
      expect(result).not_to be_a(MARS::Halt)
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
      expect(workflow).to be_a(MARS::Runnable)
    end
  end
end
