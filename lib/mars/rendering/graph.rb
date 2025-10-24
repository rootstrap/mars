# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      def self.include_extensions
        Mars::Agent.include(Agent)
        Mars::Gate.include(Gate)
        Mars::Workflows::Sequential.include(SequentialWorkflow)
        Mars::Workflows::Parallel.include(ParallelWorkflow)
        Mars::Aggregator.include(Aggregator)
      end
    end
  end
end
