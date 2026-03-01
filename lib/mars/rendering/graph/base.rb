# frozen_string_literal: true

module MARS
  module Rendering
    module Graph
      module Base
        def build_graph(builder = MARS::Rendering::Graph::Builder.new)
          builder.add_node("in", "In", Node::INPUT)
          builder.add_node("out", "Out", Node::OUTPUT)

          sink_nodes = to_graph(builder, parent_id: "in")

          sink_nodes.each do |sink_node|
            builder.add_edge(sink_node, "out")
          end

          [builder.adjacency, builder.nodes, builder.subgraphs]
        end

        def node_id
          @node_id ||= sanitize(name)
        end

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_node(node_id, name, Node::STEP)
          builder.add_edge(parent_id, node_id, value)

          [node_id]
        end

        private

        def sanitize(name)
          name.to_s.gsub(/[^a-zA-Z0-9]/, "_").downcase
        end
      end
    end
  end
end
