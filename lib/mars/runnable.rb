# frozen_string_literal: true

module MARS
  class Runnable
    include Hooks

    attr_reader :name, :formatter
    attr_accessor :state

    class << self
      def step_name
        return @step_name if defined?(@step_name)
        return unless name

        name.split("::").last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
      end

      attr_writer :step_name

      def formatter(klass = nil)
        klass ? @formatter_class = klass : @formatter_class
      end
    end

    def initialize(name: self.class.step_name, state: {}, formatter: nil)
      @name = name
      @state = state
      @formatter = formatter || self.class.formatter&.new || Formatter.new
    end

    def run(input)
      raise NotImplementedError
    end
  end
end
