# frozen_string_literal: true

module MARS
  class Context
    class Stop < StandardError
      attr_reader :result

      def initialize(result)
        @result = Result.wrap(result, stopped: true)
        super("Workflow stopped")
      end
    end

    attr_reader :current_input, :outputs, :state

    def initialize(input: nil, state: {}, global_state: nil)
      @current_input = Result.wrap(input)
      @outputs = {}
      @state = global_state || state
    end

    def [](step_name)
      outputs[step_name.to_sym]
    end

    def fetch(step_name, *default, &block)
      outputs.fetch(step_name.to_sym, *default, &block)
    end

    def record(step_name, output)
      formatted = Result.wrap(output)
      @outputs[step_name.to_sym] = formatted
      @current_input = formatted
    end

    def fork(input: current_input)
      self.class.new(input: input, state: state)
    end

    def merge(child_contexts)
      child_contexts.each do |child|
        @outputs.merge!(child.outputs)
      end

      self
    end

    def stop!(value = current_input)
      raise Stop.new(value)
    end

    alias_method :global_state, :state
  end
end
