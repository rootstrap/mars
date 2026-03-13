# frozen_string_literal: true

module MARS
  module Workflows
    class Sequential < Step
      def initialize(name, steps:, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
      end

      def run(input, ctx: {})
        nested = ctx.is_a?(Context)
        context = nested ? ctx : ensure_context(input)
        value, stopped = execute(context)

        return Result.wrap(value, stopped: false) if nested

        Result.wrap(
          value,
          stopped: stopped,
          outputs: context.outputs.dup,
          state: context.state
        )
      end

      private

      attr_reader :steps

      def ensure_context(input)
        input.is_a?(Context) ? input : Context.new(input: input)
      end

      def execute(context)
        steps.each do |step|
          result = execute_step(step, context)
          return [result, true] if result.stopped?
        rescue Context::Stop => e
          formatted = Result.wrap(step.formatter.format_output(e.result), stopped: true)
          context.record(step.name, formatted)
          step.run_after_hooks(context, formatted)
          return [formatted, true]
        end

        [context.current_input, false]
      end

      def execute_step(step, context)
        step.run_before_hooks(context)

        step_input = Result.wrap(step.formatter.format_input(context))
        result = step.run(step_input, ctx: context)
        formatted = Result.wrap(step.formatter.format_output(result))

        context.record(step.name, formatted)
        step.run_after_hooks(context, formatted)
        formatted
      end
    end
  end
end
