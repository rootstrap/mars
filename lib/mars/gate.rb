# frozen_string_literal: true

module Mars
  class Gate < Runnable
    attr_reader :name

    def initialize(name:, condition:, branches:)
      @name = name
      @condition = condition
      @branches = branches
    end

    def run(input)
      result = condition.call(input)

      # If branch exists, run it; otherwise just return input (exit)
      branches[result]&.run(input) || input
    end

    private

    attr_reader :condition, :branches
  end
end
