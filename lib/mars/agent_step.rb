# frozen_string_literal: true

module MARS
  class AgentStep < Runnable
    class << self
      def agent(klass = nil)
        klass ? @agent_class = klass : @agent_class
      end
    end

    def run(context)
      self.class.agent.new.ask(context.current_input).content
    end
  end
end
