# frozen_string_literal: true

module Mars
  module Workflows
    class Parallel < Runnable
      attr_reader :name

      def initialize(name, steps:, aggregator: nil)
        @name = name
        @steps = steps
        @aggregator = aggregator || Aggregator.new
      end

      def run(input)
        inputs = @steps.map do |step|
          step.run(input)
        end

        aggregator.run(inputs)
      end

      private

      attr_reader :steps, :aggregator
    end
  end
end
