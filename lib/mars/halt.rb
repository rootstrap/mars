# frozen_string_literal: true

module MARS
  class Halt
    attr_reader :result

    def initialize(result)
      @result = result
    end
  end
end
