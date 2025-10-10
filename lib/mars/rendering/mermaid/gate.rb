# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Gate
        include Base

        def to_mermaid
          gate_id = sanitized_name
          mermaid = ["#{gate_id}{\"#{name}\"}"]

          # Add edges for each branch
          branches.each do |condition_result, branch|
            branch_mermaid = branch.to_mermaid
            mermaid << "#{gate_id} -->|#{condition_result}| #{branch_mermaid}"
          end

          # Add the default exit path
          default_mermaid = branches.default.to_mermaid
          mermaid << "#{gate_id} -->|default| #{default_mermaid}"

          mermaid.join("\n")
        end
      end
    end
  end
end
