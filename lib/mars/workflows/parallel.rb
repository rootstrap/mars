# frozen_string_literal: true

module MARS
  module Workflows
    class Parallel < Runnable
      def initialize(name, steps:, aggregator: nil, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
        @aggregator = aggregator || Aggregator.new("#{name} Aggregator")
      end

      def run(context)
        context = ensure_context(context)
        errors = []
        child_contexts = []
        results = execute_steps(context, errors, child_contexts)

        raise AggregateError, errors if errors.any?

        context.merge(child_contexts)
        context.current_input = results
        aggregator.run(context)
      end

      private

      attr_reader :steps, :aggregator

      def execute_steps(context, errors, child_contexts)
        Async do |workflow|
          tasks = steps.map do |step|
            child_ctx = context.fork(state: step.state)
            child_contexts << child_ctx

            workflow.async do
              workflow_step(step, child_ctx)
            rescue StandardError => e
              errors << { error: e, step_name: step.name }
            end
          end

          tasks.map(&:wait)
        end.result
      end

      def workflow_step(step, child_ctx)
        step.run_before_hooks(child_ctx)

        step_input = step.formatter.format_input(child_ctx)
        child_ctx.current_input = step_input

        result = step.run(child_ctx)

        formatted = step.formatter.format_output(result)
        child_ctx.record(step.name, formatted)
        step.run_after_hooks(child_ctx, formatted)
        formatted
      end

      def ensure_context(input)
        input.is_a?(ExecutionContext) ? input : ExecutionContext.new(input: input)
      end
    end
  end
end
