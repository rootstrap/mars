# frozen_string_literal: true

module MARS
  class Aggregator < Runnable
    attr_reader :operation

    def initialize(name = "Aggregator", operation: nil, **kwargs)
      super(name: name, **kwargs)

      @operation = operation || ->(inputs) { inputs }
    end

    def run(inputs)
      if inputs.is_a?(ExecutionContext)
        operation.call(inputs.outputs)
      else
        operation.call(inputs)
      end
    end
  end
end
