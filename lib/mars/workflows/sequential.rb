# frozen_string_literal: true

module Mars
  module Workflows
    class Sequential < Runnable
      attr_reader :name

      def initialize(name, steps:, **kwargs)
        super(**kwargs)

        @name = name
        @steps = steps
      end

      def run(input)
        @steps.each do |step|
          result = step.run(input)
          return result.run(input) if result.is_a?(Runnable)

          input = result
        end

        input
      end

      private

      attr_reader :steps
    end
  end
end
