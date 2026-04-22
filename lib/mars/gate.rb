# frozen_string_literal: true

module MARS
  class Gate < Runnable
    class << self
      def check(&block)
        @check_block = block
      end

      attr_reader :check_block

      def fallback(key, runnable)
        fallbacks_map[key] = runnable
      end

      def fallbacks_map
        @fallbacks_map ||= {}
      end
    end

    def initialize(name = "Gate", check: nil, fallbacks: nil, **kwargs)
      super(name: name, **kwargs)

      @check = check || self.class.check_block
      @fallbacks = fallbacks || self.class.fallbacks_map
    end

    def run(context)
      context = ensure_context(context)
      input = context.current_input
      result = check.call(input)

      return input unless result

      branch = fallbacks[result]
      raise ArgumentError, "No fallback registered for #{result.inspect}" unless branch

      resolve_branch(branch).run(context)
    end

    private

    attr_reader :check, :fallbacks

    def resolve_branch(branch)
      branch.is_a?(Class) ? branch.new : branch
    end

    def ensure_context(input)
      input.is_a?(ExecutionContext) ? input : ExecutionContext.new(input: input)
    end
  end
end
