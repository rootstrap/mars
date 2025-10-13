# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Agent
        include Base

        def to_mermaid(add_out: false)
          "#{sanitized_name}[\"#{name}\"]"
        end

        def can_end_workflow?
          true
        end
      end
    end
  end
end
