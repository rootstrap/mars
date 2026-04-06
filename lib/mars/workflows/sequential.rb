# frozen_string_literal: true

module MARS
  module Workflows
    class Sequential < Runnable
      def initialize(name, steps:, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
      end

      def run(input)
        context = ensure_context(input)

        @steps.each do |step|
          step.run_before_hooks(context)

          step_input = step.formatter.format_input(context)
          step_context = context.fork(input: step_input, state: step.state)
          result = step.run(step_context)

          if result.is_a?(Halt)
            if result.global?
              step.run_after_hooks(context, result)
              return result
            end

            formatted = step.formatter.format_output(result.result)
            context.record(step.name, formatted)
            step.run_after_hooks(context, formatted)
            break
          end

          formatted = step.formatter.format_output(result)
          context.record(step.name, formatted)
          step.run_after_hooks(context, formatted)
        end

        context.current_input
      end

      private

      attr_reader :steps

      def ensure_context(input)
        input.is_a?(ExecutionContext) ? input : ExecutionContext.new(input: input)
      end
    end
  end
end
