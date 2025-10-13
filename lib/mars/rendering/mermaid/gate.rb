# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Gate
        include Base

        def to_mermaid(add_out: false)
          gate_id = sanitized_name
          mermaid = ["#{gate_id}{\"#{name}\"}"]

          # Add edges for each branch
          branches.each do |condition_result, branch|
            branch_first_nodes = Array(branch.first_node_id)
            mermaid << branch.to_mermaid(add_out: true)
            branch_first_nodes.each do |branch_first_node|
              mermaid << "#{gate_id} -->|#{condition_result}| #{branch_first_node}"
            end
          end

          # Add the default exit path
          default_first_nodes = Array(branches.default.first_node_id)
          mermaid << branches.default.to_mermaid(add_out: true)
          default_first_nodes.each do |default_first_node|
            mermaid << "#{gate_id} -->|default| #{default_first_node}"
          end

          mermaid.join("\n")
        end
      end
    end
  end
end
