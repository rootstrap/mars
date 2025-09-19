# frozen_string_literal: true

require_relative "../runnable"

module Mars
  module Workflows
    module Sequential < Runnable
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
    end
  end
end
