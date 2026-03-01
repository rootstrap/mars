# frozen_string_literal: true

module MARS
  module Workflows
    class Sequential < Runnable
      def initialize(name, steps:, **kwargs)
        super(name: name, **kwargs)

        @steps = steps
      end

      def run(input)
        @steps.each do |step|
          result = step.run(input)

          if result.is_a?(Runnable)
            input = result.run(input)
            break
          else
            input = result
          end
        end

        input
      end

      private

      attr_reader :steps
    end
  end
end
