# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      module ParallelWorkflow
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_node(aggregator.node_id, aggregator.name, Node::STEP)

          steps.each do |step|
            sink_nodes = step.to_graph(builder, parent_id: parent_id, value: value)
            sink_nodes.each do |sink_node|
              aggregator.to_graph(builder, parent_id: sink_node)
            end
          end

          [aggregator.node_id]
        end
      end
    end
  end
end
