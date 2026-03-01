# frozen_string_literal: true

module MARS
  class Gate < Runnable
    class << self
      def condition(&block)
        @condition_block = block
      end

      attr_reader :condition_block

      def branch(key, runnable)
        branches_map[key] = runnable
      end

      def branches_map
        @branches_map ||= {}
      end
    end

    def initialize(name = "Gate", condition: nil, branches: nil, **kwargs)
      super(name: name, **kwargs)

      @condition = condition || self.class.condition_block
      @branches = branches || self.class.branches_map
    end

    def run(input)
      result = condition.call(input)
      branch = branches[result]

      return input unless branch

      resolve_branch(branch).run(input)
    end

    private

    attr_reader :condition, :branches

    def resolve_branch(branch)
      branch.is_a?(Class) ? branch.new : branch
    end
  end
end
