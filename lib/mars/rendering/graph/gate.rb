# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      module Gate
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_node(node_id, name, Node::GATE)
          builder.add_edge(parent_id, node_id, value)

          sink_nodes = branches.map do |condition_result, branch|
            branch.to_graph(builder, parent_id: node_id, value: condition_result)
          end

          sink_nodes.flatten
        end
      end
    end
  end
end
