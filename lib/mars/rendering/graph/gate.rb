# frozen_string_literal: true

module MARS
  module Rendering
    module Graph
      module Gate
        include Base

      def to_graph(builder, parent_id: nil, value: nil)
        builder.add_node(node_id, name, Node::GATE)
        builder.add_edge(parent_id, node_id, value)

        sink_nodes = branches.map do |branch_key, branch|
          branch.to_graph(builder, parent_id: node_id, value: branch_key)
        end

        sink_nodes.flatten
      end
    end
    end
  end
end
