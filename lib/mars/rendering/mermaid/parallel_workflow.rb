# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module ParallelWorkflow
        include Base

        def to_mermaid(add_out: false)
          return "" if steps.empty?

          # Render each step
          mermaid = steps.map(&:to_mermaid)

          # Render the aggregator (use unique ID)
          mermaid << "#{aggregator_id}[\"#{aggregator.name}\"]"

          # Connect all parallel steps to the aggregator
          steps.each do |step|
            Array(step.last_node_id).each do |last_id|
              mermaid << "#{last_id} --> #{aggregator_id}"
            end
          end

          # If this parallel workflow ends the flow, connect aggregator to Out
          if add_out
            mermaid << "#{aggregator_id} --> Out((\"Out\"))"
          end

          mermaid.flatten.join("\n")
        end

        def first_node_id
          # Return array of all first nodes for parallel entry
          steps.map(&:first_node_id).flatten
        end

        def last_node_id
          # The aggregator is the last node of the parallel workflow
          aggregator_id
        end

        private

        attr_reader :steps, :aggregator

        # Generate unique aggregator ID using object_id to avoid collisions
        def aggregator_id
          "#{sanitized_name}_#{aggregator.sanitized_name}_#{object_id}"
        end
      end
    end
  end
end
