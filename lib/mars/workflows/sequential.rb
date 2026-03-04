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
          input = step.run(input)

          if input.is_a?(Halt)
            input = input.result
            break
          end
        end

        input
      end

      private

      attr_reader :steps
    end
  end
end
