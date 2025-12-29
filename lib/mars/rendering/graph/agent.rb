# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      module Agent
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_node(node_id, name, Node::STEP)
          builder.add_edge(parent_id, node_id, value)

          [node_id]
        end

        def name
          self.class.name
        end
      end
    end
  end
end
