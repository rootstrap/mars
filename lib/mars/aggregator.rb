# frozen_string_literal: true

module MARS
  class Aggregator < Runnable
    attr_reader :operation

    def initialize(name = "Aggregator", operation: nil, **kwargs)
      super(name: name, **kwargs)

      @operation = operation || ->(inputs) { inputs }
    end

    def run(context)
      context = ensure_context(context)
      operation.call(context.current_input)
    end

    private

    def ensure_context(input)
      input.is_a?(ExecutionContext) ? input : ExecutionContext.new(input: input)
    end
  end
end
