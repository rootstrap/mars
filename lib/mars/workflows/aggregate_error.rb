# frozen_string_literal: true

module Mars
  module Workflows
    class AggregateError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super(errors.map { |error| "#{error[:step_name]}: #{error[:error].message}" }.join("\n"))
      end
    end
  end
end
