# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      module Base
        def build_graph(builder = Mars::Rendering::Graph::Builder.new)
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

        private

        def sanitize(name)
          name.to_s.gsub(/[^a-zA-Z0-9]/, "_").downcase
        end
      end
    end
  end
end
