# frozen_string_literal: true

module Mars
  module Workflows
    class Sequential < Runnable
      attr_reader :name

      def initialize(name, steps:)
        @name = name
        @steps = steps
      end

      def run(input)
        @steps.each do |step|
          input = step.run(input)
        end

        input
      end

      private

      attr_reader :steps
    end
  end
end
