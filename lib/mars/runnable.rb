# frozen_string_literal: true

module Mars
  class Runnable
    attr_accessor :state

    def initialize(state: {})
      @state = state
    end

    def run(input)
      raise NotImplementedError
    end
  end
end
