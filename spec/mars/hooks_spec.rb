# frozen_string_literal: true

RSpec.describe MARS::Hooks do
  let(:hookable_class) do
    Class.new do
      include MARS::Hooks

      attr_reader :name

      def initialize(name)
        @name = name
      end
    end
  end

  describe ".before_run" do
    it "registers a before hook" do
      hookable_class.before_run { |_ctx, _step| "before" }

      expect(hookable_class.before_run_hooks.size).to eq(1)
    end
  end

  describe ".after_run" do
    it "registers an after hook" do
      hookable_class.after_run { |_ctx, _result, _step| "after" }

      expect(hookable_class.after_run_hooks.size).to eq(1)
    end
  end

  describe "#run_before_hooks" do
    it "calls all before hooks with context and step" do
      calls = []
      hookable_class.before_run { |ctx, step| calls << [ctx, step.name] }

      step = hookable_class.new("test_step")
      context = MARS::ExecutionContext.new(input: "input")
      step.run_before_hooks(context)

      expect(calls).to eq([[context, "test_step"]])
    end

    it "calls hooks in registration order" do
      order = []
      hookable_class.before_run { |_ctx, _step| order << :first }
      hookable_class.before_run { |_ctx, _step| order << :second }

      step = hookable_class.new("test_step")
      step.run_before_hooks(MARS::ExecutionContext.new(input: "input"))

      expect(order).to eq(%i[first second])
    end
  end

  describe "#run_after_hooks" do
    it "calls all after hooks with context, result, and step" do
      calls = []
      hookable_class.after_run { |ctx, result, step| calls << [ctx, result, step.name] }

      step = hookable_class.new("test_step")
      context = MARS::ExecutionContext.new(input: "input")
      step.run_after_hooks(context, "the result")

      expect(calls).to eq([[context, "the result", "test_step"]])
    end
  end

  describe "hook isolation between classes" do
    it "does not share hooks between different classes" do
      class_a = Class.new { include MARS::Hooks }
      class_b = Class.new { include MARS::Hooks }

      class_a.before_run { "a" }

      expect(class_a.before_run_hooks.size).to eq(1)
      expect(class_b.before_run_hooks.size).to eq(0)
    end
  end
end
