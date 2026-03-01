# frozen_string_literal: true

module MARS
  module Workflows
    class Sequential < Runnable
      def initialize(name, steps:, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
      end

      def self.build(name, **kwargs, &)
        builder = Builder.new
        builder.instance_eval(&)
        new(name, steps: builder.steps, **kwargs)
      end

      def run(input)
        context = input.is_a?(ExecutionContext) ? input : ExecutionContext.new(input: input)

        steps.each do |step|
          step.run_before_hooks(context)
          step_input = step.formatter.format_input(context)
          result = step.run(step_input)
          formatted = step.formatter.format_output(result)
          context.record(step.name, formatted)
          step.run_after_hooks(context, formatted)
        end

        context
      end

      private

      attr_reader :steps

      class Builder
        attr_reader :steps

        def initialize
          @steps = []
        end

        def step(runnable_class, **kwargs)
          @steps << runnable_class.new(**kwargs)
        end
      end
    end
  end
end
