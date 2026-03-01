# frozen_string_literal: true

module MARS
  class ExecutionContext
    attr_reader :current_input, :outputs, :global_state

    def initialize(input: nil, global_state: {})
      @current_input = input
      @outputs = {}
      @global_state = global_state
    end

    def [](step_name)
      outputs[step_name]
    end

    def record(step_name, output)
      @outputs[step_name] = output
      @current_input = output
    end

    def fork(input: current_input)
      self.class.new(input: input, global_state: global_state)
    end

    def merge(child_contexts)
      child_contexts.each do |child|
        @outputs.merge!(child.outputs)
      end

      self
    end
  end
end
