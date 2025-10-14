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

          # Collect all branch content
          all_lines = []

          # Collect unique branches (by object_id) to avoid rendering same branch multiple times
          unique_branches = {}
          branches.each do |condition_result, branch|
            branch_id = branch.object_id
            unique_branches[branch_id] ||= branch
          end

          # Render each unique branch once
          unique_branches.each do |branch_id, branch|
            branch_mermaid = branch.to_mermaid(add_out: true)
            all_lines.concat(branch_mermaid.split("\n")) unless branch_mermaid.empty?
          end

          # Deduplicate lines (keeps first occurrence)
          mermaid.concat(all_lines.uniq)

          # Add edges from gate to branches for all conditions
          branches.each do |condition_result, branch|
            branch_first_nodes = Array(branch.first_node_id)
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
