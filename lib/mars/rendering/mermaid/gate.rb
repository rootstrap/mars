# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Gate
        include Base

        def to_mermaid(from = 'In(("In")) -->', to = 'Out(("Out"))')
          gate_id = sanitized_name
          mermaid = ["#{gate_id}{\"#{name}\"}"]

          # Add edges for each branch
          branches.each do |condition_result, branch|
            branch_mermaid = branch.to_mermaid("#{gate_id} -->|#{condition_result}|")
            mermaid << branch_mermaid
          end

          # Add the default exit path
          default_mermaid = branches[:default].to_mermaid("#{gate_id} -->|default|")
          mermaid << default_mermaid

          mermaid
        end
      end
    end
  end
end
