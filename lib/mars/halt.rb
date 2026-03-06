# frozen_string_literal: true

module MARS
  class Halt
    attr_reader :result, :scope

    def initialize(result, scope: :local)
      @result = result
      @scope = scope
    end

    def local? = scope == :local
    def global? = scope == :global
  end
end
