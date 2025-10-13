# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module SequentialWorkflow
        include Base

        def to_mermaid(add_out: false)
          return "" if steps.empty?

          mermaid = steps.map.with_index do |current_step, index|
            step_to_mermaid(current_step, index, add_out: add_out && index == steps.length - 1)
          end

          mermaid.flatten.join("\n")
        end

        def first_node_id
          steps.first&.first_node_id || sanitized_name
        end

        def last_node_id
          steps.last&.last_node_id || sanitized_name
        end

        private

        def step_to_mermaid(current_step, index, add_out:)
          current_ids = Array(current_step.last_node_id)
          next_nodes = next_node(current_step, index, add_out: add_out)

          step_mermaid = [current_step.to_mermaid(add_out: add_out)]

          # Generate connections: each current_id connects to each next_node
          if next_nodes
            Array(next_nodes).each do |next_node|
              current_ids.each do |current_id|
                step_mermaid << "#{current_id} --> #{next_node}"
              end
            end
          end

          step_mermaid
        end

        def next_node(step, index, add_out:)
          if index < steps.length - 1
            steps[index + 1].first_node_id
          elsif add_out && step.can_end_workflow?
            "Out((\"Out\"))"
          end
        end
      end
    end
  end
end
