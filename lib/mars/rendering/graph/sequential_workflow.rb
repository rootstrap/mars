# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      module SequentialWorkflow
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          sink_nodes = []

          builder.add_subgraph(node_id, name) if steps.any?

          steps.each do |step|
            sink_nodes = step.to_graph(builder, parent_id: parent_id, value: value)
            value = nil # We don't want to pass the value to subsequent steps
            parent_id = step.node_id

            builder.add_node_to_subgraph(node_id, step.node_id)

            sink_nodes.each do |sink_node|
              builder.add_node_to_subgraph(node_id, sink_node)
            end
          end

          builder.add_edge(parent_id, "out", value) if sink_nodes.empty?

          sink_nodes.flatten
        end
      end
    end
  end
end
