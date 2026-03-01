# frozen_string_literal: true

module MARS
  class Gate < Runnable
    def initialize(name = "Gate", condition:, branches:, **kwargs)
      super(name: name, **kwargs)

      @condition = condition
      @branches = branches
    end

    def run(input)
      result = condition.call(input)

      branches[result] || input
    end

    private

    attr_reader :condition, :branches
  end
end
