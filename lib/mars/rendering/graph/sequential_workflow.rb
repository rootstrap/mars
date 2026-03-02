# frozen_string_literal: true

module MARS
  module Rendering
    module Graph
      module SequentialWorkflow
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_subgraph(node_id, name) if steps.any?

          parent_id, value, sink_nodes = build_steps_graph(builder, parent_id, value)

          builder.add_edge(parent_id, "out", value) if sink_nodes.empty?

          sink_nodes.flatten
        end

        private

        def build_steps_graph(builder, parent_id, value)
          sink_nodes = []
          extra_parents = []

          steps.each do |step|
            sink_nodes = step.to_graph(builder, parent_id: parent_id, value: value)
            extra_parents.each { |ep| builder.add_edge(ep, step.node_id) }

            value = nil
            parent_id, extra_parents = process_sink_nodes(sink_nodes, step)

            add_to_subgraph(builder, step, sink_nodes)
          end

          [parent_id, value, sink_nodes]
        end

        def process_sink_nodes(sink_nodes, step)
          unique_sinks = sink_nodes.uniq
          [unique_sinks.first || step.node_id, unique_sinks.drop(1)]
        end

        def add_to_subgraph(builder, step, sink_nodes)
          builder.add_node_to_subgraph(node_id, step.node_id)
          sink_nodes.each { |sink_node| builder.add_node_to_subgraph(node_id, sink_node) }
        end
      end
    end
  end
end
