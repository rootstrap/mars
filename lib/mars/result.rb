# frozen_string_literal: true

module MARS
  class Result
    attr_reader :value, :outputs, :state

    def self.wrap(result, stopped: nil, outputs: nil, state: nil)
      wrapped =
        case result
        when self
          result
        when Hash
          if envelope_hash?(result)
            new(
              value: result[:value],
              stopped: result.fetch(:stopped, false),
              outputs: result.fetch(:outputs, {}),
              state: result[:state]
            )
          else
            new(value: result)
          end
        else
          new(value: result)
        end

      wrapped.with(
        stopped: stopped.nil? ? wrapped.stopped? : stopped,
        outputs: outputs || wrapped.outputs,
        state: state || wrapped.state
      )
    end

    def initialize(value:, stopped: false, outputs: {}, state: nil)
      @value = value
      @stopped = stopped
      @outputs = outputs
      @state = state
    end

    def [](key)
      case key.to_sym
      when :value
        value
      when :stopped
        stopped?
      when :outputs
        outputs
      when :state
        state
      else
        outputs[key.to_sym]
      end
    end

    def stopped?
      @stopped
    end

    def ok?
      !stopped?
    end

    def with(value: self.value, stopped: stopped?, outputs: self.outputs, state: self.state)
      self.class.new(
        value: value,
        stopped: stopped,
        outputs: outputs,
        state: state
      )
    end

    def to_h
      {
        value: value,
        stopped: stopped?,
        outputs: outputs,
        state: state
      }
    end

    def ==(other)
      other.is_a?(self.class) && to_h == other.to_h
    end

    def self.envelope_hash?(result)
      result.key?(:value) || result.key?(:stopped) || result.key?(:outputs) || result.key?(:state)
    end
    private_class_method :envelope_hash?
  end
end
