# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module ParallelWorkflow
        include Base

        # WIP
        def to_mermaid(from = 'In(("In")) -->', to = 'Out(("Out"))')
          return "" if steps.empty?

          aggregator_mermaid = aggregator.to_mermaid

          mermaid = steps.map do |current_step|
            step_to_mermaid(current_step, from, to) + [aggregator_mermaid]
          end

          mermaid
        end

        private

        def step_to_mermaid(current_step, from, to)
          current_id = current_step.sanitized_name
          next_node = next_node(current_step)
          current_step_mermaid = current_step.to_mermaid

          step_mermaid = [from]
          step_mermaid << current_step.to_mermaid
          step_mermaid << "#{from} --> #{current_step.to_mermaid.first}" if next_node

          step_mermaid
        end
      end
    end
  end
end
