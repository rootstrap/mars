module Mars
  module Rendering
    module Mermaid
      def self.include_extensions
        Mars::Agent.include(Agent)
        Mars::Exit.include(Exit)
        Mars::Gate.include(Gate)
        Mars::Workflows::Sequential.include(SequentialWorkflow)
      end
    end
  end
end
