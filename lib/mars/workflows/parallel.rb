# frozen_string_literal: true

module Mars
  module Workflows
    class Parallel < Runnable
      attr_reader :name

      def initialize(name, steps:, aggregator: nil, **kwargs)
        super(**kwargs)

        @name = name
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

        aggregator.run(results)
      end

      private

      attr_reader :steps, :aggregator
    end
  end
end
