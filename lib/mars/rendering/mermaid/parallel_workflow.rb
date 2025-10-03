# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module ParallelWorkflow
        include Base

        # WIP
        def to_mermaid
          return "" if steps.empty?

          aggregator_mermaid = aggregator.to_mermaid

          mermaid = steps.map do |current_step|
            step_to_mermaid(current_step) + aggregator_mermaid
          end

          mermaid.flatten.join("\n")
        end

        private

        def step_to_mermaid(current_step)
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
