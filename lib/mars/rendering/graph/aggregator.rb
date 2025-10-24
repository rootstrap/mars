# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      module Aggregator
        include Base

        def to_graph(builder, parent_id: nil, value: nil)
          builder.add_edge(parent_id, node_id, value)

          [node_id]
        end
      end
    end
  end
end
