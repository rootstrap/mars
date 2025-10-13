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

          # If this parallel workflow ends the flow, connect all steps to Out
          if add_out && steps.all?(&:can_end_workflow?)
            steps.each do |step|
              Array(step.last_node_id).each do |last_id|
                mermaid << "#{last_id} --> Out((\"Out\"))"
              end
            end
          end

          mermaid.flatten.join("\n")
        end

        def first_node_id
          # Return array of all first nodes for parallel entry
          steps.map(&:first_node_id).flatten
        end

        def last_node_id
          # Return array of all last nodes for parallel exit
          steps.map(&:last_node_id).flatten
        end

        private

        attr_reader :steps
      end
    end
  end
end
