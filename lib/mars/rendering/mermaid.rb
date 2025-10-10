# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      def self.include_extensions
        Mars::Agent.include(Agent)
        Mars::Exit.include(Exit)
        Mars::Gate.include(Gate)
        Mars::Workflows::Sequential.include(SequentialWorkflow)
        Mars::Workflows::Parallel.include(ParallelWorkflow)
        Mars::Aggregator.include(Aggregator)
      end

      def self.render(obj, options = {})
        direction = options.fetch(:direction, "LR")

        <<~MERMAID
          ```mermaid
          flowchart #{direction}
          #{obj.to_mermaid.flatten.join("\n")}
          ```
        MERMAID
      end
    end
  end
end
