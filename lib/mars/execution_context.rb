# frozen_string_literal: true

module MARS
  class ExecutionContext
    attr_reader :outputs, :global_state
    attr_accessor :current_input

    def initialize(input: nil, global_state: {})
      @current_input = input
      @outputs = {}
      @global_state = global_state
    end

    def [](step_name)
      outputs[step_name.to_sym]
    end

    def record(step_name, output)
      @outputs[step_name.to_sym] = output
      @current_input = output
    end

    def fork(input: current_input, state: {})
      self.class.new(input: input, global_state: global_state.merge(state))
    end

    def merge(child_contexts)
      child_contexts.each do |child|
        @outputs.merge!(child.outputs)
      end

      self
    end
  end
end
