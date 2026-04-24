# frozen_string_literal: true

module MARS
  module Workflows
    class Sequential < Runnable
      def initialize(name, steps:, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
      end

      def run(context)
        context = ensure_context(context)

        @steps.each do |step|
          step.run_before_hooks(context)

          step_input = step.formatter.format_input(context)
          context.current_input = step_input

          result = step.run(context)

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
