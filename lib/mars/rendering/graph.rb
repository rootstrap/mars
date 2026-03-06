# frozen_string_literal: true

module MARS
  module Rendering
    module Graph
      def self.include_extensions
        MARS::Runnable.include(Runnable)
        MARS::AgentStep.include(AgentStep)
        MARS::Gate.include(Gate)
        MARS::Workflows::Sequential.include(SequentialWorkflow)
        MARS::Workflows::Parallel.include(ParallelWorkflow)
        MARS::Aggregator.include(Aggregator)
      end
    end
  end
end
