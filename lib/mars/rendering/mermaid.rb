# frozen_string_literal: true

module Mars
  module Rendering
    class Mermaid
      attr_reader :obj, :graph, :nodes

      def initialize(obj)
        @obj = obj
        @graph, @nodes = obj.build_graph
      end

      def render(options = {})
        direction = options.fetch(:direction, "LR")
        mermaid = graph_mermaid.join("\n")

        <<~MERMAID
          ```mermaid
          flowchart #{direction}
          #{mermaid}
          ```
        MERMAID
      end

      def graph_mermaid
        nodes_mermaid = nodes.keys.map { |node_id| "#{node_id}#{shape(node_id)}" }
        edges_mermaid = []

        graph.each do |from, tos|
          tos.each do |to|
            node_id, value = to
            edges_mermaid << "#{from} -->#{edge_value(value)} #{node_id}"
          end
        end

        nodes_mermaid + edges_mermaid
      end

      def shape(node_id)
        node = nodes[node_id]

        case node.type
        when Graph::Node::INPUT, Graph::Node::OUTPUT
          "((#{node.name}))"
        when Graph::Node::GATE
          "{#{node.name}}"
        else
          "[#{node.name}]"
        end
      end

      def edge_value(value)
        return "" unless value

        "|#{value}|"
      end
    end
  end
end
