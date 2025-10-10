# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Base
        def sanitized_name
          name.to_s.gsub(/[^a-zA-Z0-9_]/, "_")
        end

        def can_end_workflow?
          false
        end
      end
    end
  end
end
