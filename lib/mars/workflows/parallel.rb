# frozen_string_literal: true

module MARS
  module Workflows
    class Parallel < Runnable
      def initialize(name, steps:, aggregator: nil, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
        @aggregator = aggregator || Aggregator.new("#{name} Aggregator")
      end

      def run(input)
        context = input.is_a?(ExecutionContext) ? input : ExecutionContext.new(input: input)

        errors = []
        child_contexts = run_steps_async(context, errors)

        raise AggregateError, errors if errors.any?

        context.merge(child_contexts)
        aggregator.run(context)
      end

      private

      attr_reader :steps, :aggregator

      def run_steps_async(context, errors)
        Async do |workflow|
          tasks = steps.map do |step|
            workflow.async { run_step(context.fork, step, errors) }
          end

          tasks.map(&:wait)
        end.result
      end

      def run_step(child, step, errors)
        step.run_before_hooks(child)
        step_input = step.formatter.format_input(child)
        result = step.run(step_input)
        formatted = step.formatter.format_output(result)
        child.record(step.name, formatted)
        step.run_after_hooks(child, formatted)
        child
      rescue StandardError => e
        errors << { error: e, step_name: step.name }
      end
    end
  end
end
