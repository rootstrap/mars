# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      module ParallelWorkflow
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_subgraph(node_id, name) if steps.any?
          builder.add_node(aggregator.node_id, aggregator.name, Node::STEP)

          build_steps_graph(builder, parent_id, value)

          [aggregator.node_id]
        end

        private

        def build_steps_graph(builder, parent_id, value)
          steps.each do |step|
            sink_nodes = step.to_graph(builder, parent_id: parent_id, value: value)

            builder.add_node_to_subgraph(node_id, step.node_id)

            sink_nodes.each do |sink_node|
              aggregator.to_graph(builder, parent_id: sink_node)
            end
          end
        end
      end
    end
  end
end
