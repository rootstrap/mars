# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module SequentialWorkflow
        include Base

        def to_mermaid
          return "" if steps.empty?

          mermaid = steps.map.with_index do |current_step, index|
            step_to_mermaid(current_step, index)
          end

          mermaid.flatten.join("\n")
        end

        private

        def step_to_mermaid(current_step, index)
          current_id = current_step.sanitized_name
          next_node = next_node(current_step, index)

          step_mermaid = [current_step.to_mermaid]
          step_mermaid << "#{current_id} --> #{next_node}" if next_node

          step_mermaid
        end

        def next_node(step, index)
          if index < steps.length - 1
            steps[index + 1].sanitized_name
          elsif step.can_end_workflow?
            "Out((\"Out\"))"
          end
        end
      end
    end
  end
end
