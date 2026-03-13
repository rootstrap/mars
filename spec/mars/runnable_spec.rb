# frozen_string_literal: true

RSpec.describe MARS::Runnable do
  describe "#run" do
    context "when called directly on the base class" do
      let(:runnable) { described_class.new }

      it "raises NotImplementedError" do
        expect { runnable.run({ value: "any input" }, ctx: {}) }.to raise_error(NotImplementedError)
      end
    end

    context "when implemented in a subclass" do
      let(:test_runnable_class) do
        Class.new(MARS::Runnable) do
          def run(input, ctx: {})
            MARS::Result.new(value: "processed: #{input.value}")
          end
        end
      end

      let(:runnable) { test_runnable_class.new }

      it "can be successfully overridden" do
        result = runnable.run(MARS::Result.new(value: "test input"), ctx: {})
        expect(result).to eq(MARS::Result.new(value: "processed: test input"))
      end
    end

    context "when subclass doesn't override run method" do
      let(:incomplete_runnable_class) do
        Class.new(MARS::Runnable) do
          # Intentionally not overriding run method
        end
      end

      let(:runnable) { incomplete_runnable_class.new }

      it "still raises NotImplementedError" do
        expect { runnable.run(MARS::Result.new(value: "input"), ctx: {}) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#name" do
    it "defaults to nil for anonymous classes" do
      klass = Class.new(described_class)
      expect(klass.new.name).to be_nil
    end

    it "can be set via the name keyword" do
      runnable = described_class.new(name: "my_step")
      expect(runnable.name).to eq("my_step")
    end

    it "derives step_name from the class name" do
      stub_const("MARS::MyCustomStep", Class.new(described_class))
      expect(MARS::MyCustomStep.new.name).to eq("my_custom_step")
    end
  end

  describe "#formatter" do
    it "defaults to a Formatter instance" do
      runnable = described_class.new
      expect(runnable.formatter).to be_a(MARS::Formatter)
    end

    it "can be set via the formatter keyword" do
      custom_formatter = MARS::Formatter.new
      runnable = described_class.new(formatter: custom_formatter)
      expect(runnable.formatter).to eq(custom_formatter)
    end

    it "uses the class-level formatter when declared" do
      custom_formatter_class = Class.new(MARS::Formatter)
      klass = Class.new(described_class) do
        formatter custom_formatter_class
      end

      expect(klass.new.formatter).to be_a(custom_formatter_class)
    end
  end

  describe "hooks" do
    it "includes Hooks module" do
      expect(described_class.ancestors).to include(MARS::Hooks)
    end

    it "supports before_run hooks" do
      klass = Class.new(described_class)
      calls = []
      klass.before_run { |_ctx, step| calls << step.name }

      step = klass.new(name: "test")
      step.run_before_hooks(MARS::Context.new(input: "x"))

      expect(calls).to eq(["test"])
    end

    it "supports after_run hooks" do
      klass = Class.new(described_class)
      calls = []
      klass.after_run { |_ctx, result, _step| calls << result }

      step = klass.new(name: "test")
      result = MARS::Result.new(value: "result")
      step.run_after_hooks(MARS::Context.new(input: "x"), result)

      expect(calls).to eq([result])
    end
  end

  describe "inheritance" do
    it "can be inherited" do
      subclass = Class.new(described_class)
      expect(subclass.ancestors).to include(described_class)
    end
  end
end
