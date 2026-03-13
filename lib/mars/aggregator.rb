# frozen_string_literal: true

module MARS
  class Aggregator < Step
    attr_reader :operation

    def initialize(name = "Aggregator", operation: nil, **kwargs)
      super(name: name, **kwargs)

      @operation = operation || ->(inputs, _ctx) { inputs }
    end

    def run(inputs, ctx: {})
      Result.wrap(operation.call(inputs, ctx))
    end
  end
end
