# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Gate
        include Base

        # Gates don't connect to Out themselves - their branches do
        def last_node_id
          nil
        end

        def to_mermaid(add_out: false)
          gate_id = sanitized_name
          mermaid = ["#{gate_id}{\"#{name}\"}"]

          # Add edges for each branch
          branches.each do |condition_result, branch|
            branch_first_nodes = Array(branch.first_node_id)
            branch_mermaid = branch.to_mermaid(add_out: true)
            mermaid << branch_mermaid unless branch_mermaid.empty?
            branch_first_nodes.each do |branch_first_node|
              mermaid << "#{gate_id} -->|#{condition_result}| #{branch_first_node}"
            end
          end

          # Add the default exit path (always goes to Out)
          mermaid << "#{gate_id} -->|default| Out((\"Out\"))"

          mermaid.join("\n")
        end
      end
    end
  end
end
