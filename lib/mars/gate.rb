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

      branches[result].run(input)
    end

    private

    attr_reader :condition, :branches
  end
end
