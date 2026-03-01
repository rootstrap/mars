# frozen_string_literal: true

module MARS
  module Rendering
    class Mermaid
      attr_reader :obj, :graph, :nodes, :subgraphs

      def initialize(obj)
        @obj = obj
        @graph, @nodes, @subgraphs = obj.build_graph
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
        top_level_nodes_mermaid + subgraphs_mermaid + edges_mermaid
      end

      def top_level_nodes_mermaid
        subgraph_node_ids = subgraphs.values.flat_map(&:nodes).to_set
        nodes.keys.reject { |id| subgraph_node_ids.include?(id) }.map { |id| node_definition(id) }
      end

      def node_definition(node_id)
        "#{node_id}#{shape(node_id)}"
      end

      def subgraphs_mermaid
        root_ids = subgraphs.keys - nested_subgraph_ids
        root_ids.map { |id| render_subgraph(id) }
      end

      def edges_mermaid
        edges = []
        graph.each do |from, tos|
          tos.each do |to|
            node_id, value = to
            edges << "#{from} -->#{edge_value(value)} #{node_id}"
          end
        end
        edges
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

      private

      def nested_subgraph_ids
        ids = []
        subgraphs.each_value do |sg|
          sg.nodes.each { |n| ids << n if subgraphs.key?(n) }
        end
        ids
      end

      def render_subgraph(id, indent = "")
        sg = subgraphs[id]
        lines = ["#{indent}subgraph #{sg.id}[\"#{sg.name}\"]"]
        sg.nodes.each { |node_id| lines << render_subgraph_node(node_id, indent) }
        lines << "#{indent}end"
        lines.join("\n")
      end

      def render_subgraph_node(node_id, indent)
        if subgraphs.key?(node_id)
          render_subgraph(node_id, "#{indent}  ")
        else
          "#{indent}  #{node_definition(node_id)}"
        end
      end
    end
  end
end
