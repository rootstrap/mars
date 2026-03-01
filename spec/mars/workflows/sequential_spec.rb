# frozen_string_literal: true

RSpec.describe MARS::Workflows::Sequential do
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
    it "executes steps sequentially and returns context" do
      add_five = add_step_class.new(value: 5, name: "add_five")
      multiply_three = multiply_step_class.new(multiplier: 3, name: "multiply_three")
      add_two = add_step_class.new(value: 2, name: "add_two")

      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three, add_two])
      context = workflow.run(10)

      # 10 + 5 = 15, 15 * 3 = 45, 45 + 2 = 47
      expect(context.current_input).to eq(47)
    end

    it "records each step output in the context" do
      add_five = add_step_class.new(value: 5, name: "add_five")
      multiply_three = multiply_step_class.new(multiplier: 3, name: "multiply_three")

      workflow = described_class.new("math_workflow", steps: [add_five, multiply_three])
      context = workflow.run(10)

      expect(context[:add_five]).to eq(15)
      expect(context[:multiply_three]).to eq(45)
    end

    it "handles single step" do
      multiply_step = multiply_step_class.new(multiplier: 7, name: "multiply")
      workflow = described_class.new("single_step", steps: [multiply_step])

      context = workflow.run(6)
      expect(context.current_input).to eq(42)
    end

    it "returns context with original input when no steps" do
      workflow = described_class.new("empty", steps: [])

      context = workflow.run(42)
      expect(context.current_input).to eq(42)
    end

    it "propagates errors from steps" do
      add_step = add_step_class.new(value: 5, name: "add")
      error_step = error_step_class.new(message: "Step failed", name: "error")

      workflow = described_class.new("error_workflow", steps: [add_step, error_step])

      expect { workflow.run(10) }.to raise_error(StandardError, "Step failed")
    end

    it "accepts an existing ExecutionContext" do
      add_step = add_step_class.new(value: 1, name: "add")
      workflow = described_class.new("ctx_workflow", steps: [add_step])

      ctx = MARS::ExecutionContext.new(input: 100, global_state: { key: "val" })
      result = workflow.run(ctx)

      expect(result.current_input).to eq(101)
      expect(result.global_state[:key]).to eq("val")
    end

    it "runs before and after hooks" do
      hook_log = []
      step_class = Class.new(MARS::Runnable) do
        before_run { |_ctx, step| hook_log << "before:#{step.name}" }
        after_run { |_ctx, result, step| hook_log << "after:#{step.name}:#{result}" }

        def run(input)
          input.upcase
        end
      end

      # capture hook_log in the closure
      local_log = hook_log
      step_class.define_method(:hook_log) { local_log }

      step = step_class.new(name: "upper")
      workflow = described_class.new("hook_workflow", steps: [step])
      workflow.run("hello")

      expect(hook_log).to eq(["before:upper", "after:upper:HELLO"])
    end

    it "applies formatters" do
      custom_formatter_class = Class.new(MARS::Formatter) do
        def format_input(context)
          "prefix:#{context.current_input}"
        end

        def format_output(output)
          "#{output}:suffix"
        end
      end

      step_class = Class.new(MARS::Runnable) do
        def run(input)
          input.upcase
        end
      end

      step = step_class.new(name: "fmt_step", formatter: custom_formatter_class.new)
      workflow = described_class.new("fmt_workflow", steps: [step])
      context = workflow.run("hello")

      expect(context[:fmt_step]).to eq("PREFIX:HELLO:suffix")
    end
  end

  describe ".build" do
    it "builds a workflow from a block" do
      step_class = Class.new(MARS::Runnable) do
        self.step_name = "my_step"

        def run(input)
          "#{input}!"
        end
      end
      stub_const("ExclaimStep", step_class)

      workflow = described_class.build("built") do
        step ExclaimStep
      end

      context = workflow.run("hello")
      expect(context.current_input).to eq("hello!")
    end
  end

  describe "inheritance" do
    it "inherits from MARS::Runnable" do
      workflow = described_class.new("test", steps: [])
      expect(workflow).to be_a(MARS::Runnable)
    end
  end
end
