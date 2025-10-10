# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module SequentialWorkflow
        include Base

        def to_mermaid(from = 'In(("In")) -->', to = 'Out(("Out"))')
          return "" if steps.empty?

          mermaid = first_step_mermaid(from, steps.first) + steps.map.with_index do |current_step, index|
            step_to_mermaid(current_step, index, to)
          end

          mermaid.flatten
        end

        private

        def first_step_mermaid(from, step)
          ["#{from} #{step.to_mermaid.first}"]
        end

        def step_to_mermaid(current_step, index, to)
          current_id = current_step.sanitized_name
          next_node = next_node(current_step, index, to)

          step_mermaid = [current_step.to_mermaid]
          step_mermaid << "#{current_id} --> #{next_node}" if next_node

          step_mermaid
        end

        def next_node(step, index, to)
          if index < steps.length - 1
            steps[index + 1].sanitized_name
          elsif step.can_end_workflow?
            to
          end
        end
      end
    end
  end
end
