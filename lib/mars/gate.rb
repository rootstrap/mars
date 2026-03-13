# frozen_string_literal: true

module MARS
  class Gate < Step
    class << self
      def check(&block)
        @check_block = block
      end

      attr_reader :check_block

      def branch(key, runnable)
        branches_map[key] = runnable
      end

      def fallback(key, runnable)
        branch(key, runnable)
      end

      def branches_map
        @branches_map ||= {}
      end
    end

    def initialize(name = "Gate", check: nil, branches: nil, fallbacks: nil, **kwargs)
      super(name: name, **kwargs)

      @check = check || self.class.check_block
      @branches = branches || fallbacks || self.class.branches_map
    end

    def run(input, ctx: {})
      input = Result.wrap(input)
      local_ctx = ctx.is_a?(Context) ? ctx : Context.new(input: input)
      decision = evaluate_check(input, local_ctx)

      return input unless decision

      branch = branches[decision]
      raise ArgumentError, "No branch registered for #{decision.inspect}" unless branch

      branch_result = resolve_branch(branch).run(input, ctx: local_ctx.fork(input: input))
      Result.wrap(branch_result, stopped: true)
    end

    private

    attr_reader :check, :branches

    def evaluate_check(input, ctx)
      check.call(input, ctx)
    end

    def resolve_branch(branch)
      branch.is_a?(Class) ? branch.new : branch
    end
  end
end
