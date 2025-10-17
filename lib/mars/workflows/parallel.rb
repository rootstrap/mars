# frozen_string_literal: true

require "async"

module Mars
  module Workflows
    class Parallel < Runnable
      attr_reader :name

      def initialize(name, steps:, aggregator: nil)
        @name = name
        @steps = steps
        @aggregator = aggregator || Aggregator.new("#{name} Aggregator")
      end

      def run(input)
        results = Async do |workflow|
          tasks = @steps.map do |step|
            workflow.async do
              step.run(input)
            end
          end

          tasks.map(&:wait)
        end.result

        aggregator.run(results)
      end

      private

      attr_reader :steps, :aggregator
    end
  end
end
