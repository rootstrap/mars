# frozen_string_literal: true

module Mars
  class Gate < Runnable
    def initialize(name:, condition:, branches:)
      @name = name
      @condition = condition
      @branches = branches
    end

    def run(input)
      result = condition.call(input)

      raise "Invalid condition result: #{result}" unless branches.key?(result)

      branches[result].run(input)
    end

    private

    attr_reader :name, :condition, :branches
  end
end
