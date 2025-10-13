# frozen_string_literal: true

module Mars
  module Rendering
    module Mermaid
      module Exit
        include Base

        def to_mermaid(add_out: false)
          "exit((#{name}))"
        end

        def first_node_id
          "exit"
        end

        def last_node_id
          "exit"
        end
      end
    end
  end
end
