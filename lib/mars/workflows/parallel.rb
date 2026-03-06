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
        errors = []
        results = execute_steps(input, errors)

        raise AggregateError, errors if errors.any?

        has_global_halt = results.any? { |r| r.is_a?(Halt) && r.global? }
        unwrapped = results.map { |r| r.is_a?(Halt) ? r.result : r }
        result = aggregator.run(unwrapped)
        has_global_halt ? Halt.new(result, scope: :global) : result
      end

      private

      attr_reader :steps, :aggregator

      def execute_steps(input, errors)
        Async do |workflow|
          tasks = steps.map do |step|
            workflow.async do
              step.run(input)
            rescue StandardError => e
              errors << { error: e, step_name: step.name }
            end
          end

          tasks.map(&:wait)
        end.result
      end
    end
  end
end
