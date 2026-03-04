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
        results = Async do |workflow|
          tasks = @steps.map do |step|
            workflow.async do
              step.run(input)
            rescue StandardError => e
              errors << { error: e, step_name: step.name }
            end
          end

          tasks.map(&:wait)
        end.result

        raise AggregateError, errors if errors.any?

        has_halt = results.any? { |r| r.is_a?(Halt) }
        result = aggregator.run(results)
        has_halt ? Halt.new(result) : result
      end

      private

      attr_reader :steps, :aggregator
    end
  end
end
