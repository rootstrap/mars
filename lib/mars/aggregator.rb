# frozen_string_literal: true

module Mars
  class Aggregator < Runnable
    attr_reader :name

    def initialize(name = "Aggregator")
      @name = name
    end

    def run(inputs)
      return yield if block_given?

      inputs.join("\n")
    end
  end
end
