# frozen_string_literal: true

module MARS
  module Rendering
    module Graph
      module ParallelWorkflow
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_subgraph(node_id, name) if steps.any?
          builder.add_node(aggregator.node_id, aggregator.name, Node::STEP) if aggregator

          sink_nodes = build_steps_graph(builder, parent_id, value)

          aggregator ? [aggregator.node_id] : sink_nodes
        end

        private

        def build_steps_graph(builder, parent_id, value)
          all_sink_nodes = []

          steps.each do |step|
            sink_nodes = step.to_graph(builder, parent_id: parent_id, value: value)
            all_sink_nodes.concat(sink_nodes)

            builder.add_node_to_subgraph(node_id, step.node_id)

            sink_nodes.each do |sink_node|
              builder.add_edge(sink_node, aggregator.node_id) if aggregator
            end
          end

          all_sink_nodes
        end
      end
    end
  end
end
