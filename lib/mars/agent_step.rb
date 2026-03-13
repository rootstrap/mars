# frozen_string_literal: true

module MARS
  class AgentStep < Step
    class << self
      def agent(klass = nil)
        klass ? @agent_class = klass : @agent_class
      end
    end

    def run(input, ctx: {})
      result(value: self.class.agent.new.ask(input.value).content)
    end
  end
end
