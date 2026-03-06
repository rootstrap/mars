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

      def halt_scope(scope = nil)
        scope ? @halt_scope = scope : @halt_scope
      end
    end

    def initialize(name = "Gate", check: nil, fallbacks: nil, halt_scope: nil, **kwargs)
      super(name: name, **kwargs)

      @check = check || self.class.check_block
      @fallbacks = fallbacks || self.class.fallbacks_map
      @halt_scope = halt_scope || self.class.halt_scope || :local
    end

    def run(input)
      result = check.call(input)

      return input unless result

      branch = fallbacks[result]
      raise ArgumentError, "No fallback registered for #{result.inspect}" unless branch

      Halt.new(resolve_branch(branch).run(input), scope: @halt_scope)
    end

    private

    attr_reader :check, :fallbacks

    def resolve_branch(branch)
      branch.is_a?(Class) ? branch.new : branch
    end
  end
end
