# frozen_string_literal: true

module MARS
  class AgentStep < Runnable
    class << self
      def agent(klass = nil)
        klass ? @agent_class = klass : @agent_class
      end
    end

    def run(input)
      self.class.agent.new.ask(input).content
    end
  end
end
