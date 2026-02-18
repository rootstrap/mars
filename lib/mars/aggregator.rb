# frozen_string_literal: true

module Mars
  class Aggregator < Runnable
    attr_reader :name, :operation

    def initialize(name = "Aggregator", operation: nil, **kwargs)
      super(**kwargs)

      @name = name
      @operation = operation || ->(inputs) { inputs }
    end

    def run(inputs)
      operation.call(inputs)
    end
  end
end
