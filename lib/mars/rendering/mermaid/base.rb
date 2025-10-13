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

        # Returns the ID(s) of the first node(s) for mermaid connections
        # Can return a String for single entry point or Array for multiple (e.g. parallel workflows)
        def first_node_id
          sanitized_name
        end

        # Returns the ID(s) of the last node(s) for mermaid connections
        # Can return a String for single exit point or Array for multiple (e.g. parallel workflows)
        def last_node_id
          sanitized_name
        end
      end
    end
  end
end
