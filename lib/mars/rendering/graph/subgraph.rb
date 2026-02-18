# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      class Subgraph
        attr_reader :id, :name, :nodes

        def initialize(id, name, nodes)
          @id = id
          @name = name
          @nodes = nodes
        end
      end
    end
  end
end
