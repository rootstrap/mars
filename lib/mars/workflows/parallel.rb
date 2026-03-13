# frozen_string_literal: true

module MARS
  module Workflows
    class Parallel < Step
      def initialize(name, steps:, aggregator: nil, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
        @aggregator = aggregator
      end

      def run(input, ctx: {})
        nested = ctx.is_a?(Context)
        context = nested ? ctx : ensure_context(input)
        errors = []
        child_contexts = []
        results = execute_steps(context, errors, child_contexts)

        raise AggregateError, errors if errors.any?

        context.merge(child_contexts)

        value = aggregator ? aggregator.run(results, ctx: context) : result(value: results)

        return Result.wrap(value, stopped: false) if nested

        Result.wrap(
          value,
          outputs: context.outputs.dup,
          state: context.state
        )
      end

      private

      attr_reader :steps, :aggregator

      def ensure_context(input)
        input.is_a?(Context) ? input : Context.new(input: input)
      end

      def execute_steps(context, errors, child_contexts)
        Async do |workflow|
          tasks = steps.map do |step|
            child_ctx = context.fork
            child_contexts << child_ctx

            workflow.async do
              execute_step(step, child_ctx)
            rescue StandardError => e
              errors << { error: e, step_name: step.name }
            end
          end

          tasks.map(&:wait).compact
        end.result
      end

      def execute_step(step, child_ctx)
        step.run_before_hooks(child_ctx)

        step_input = Result.wrap(step.formatter.format_input(child_ctx))
        result = step.run(step_input, ctx: child_ctx)
        formatted = Result.wrap(step.formatter.format_output(result))

        child_ctx.record(step.name, formatted)
        step.run_after_hooks(child_ctx, formatted)
        formatted
      rescue Context::Stop => e
        formatted = Result.wrap(step.formatter.format_output(e.result), stopped: true)
        child_ctx.record(step.name, formatted)
        step.run_after_hooks(child_ctx, formatted)
        formatted
      end
    end
  end
end
