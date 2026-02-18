# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      class Builder
        attr_reader :adjacency, :nodes, :subgraphs

        def initialize
          @adjacency = Hash.new { |h, k| h[k] = [] }
          @nodes = {}
          @subgraphs = {}
        end

        def add_edge(from, to, value = nil)
          return unless from && to

          # can we avoid visiting the node twice instead?
          adjacency[from] << [to, value] unless adjacency[from].include?([to, value])
          adjacency[to] = [] unless adjacency[to]
        end

        def add_node(id, value, type)
          return if nodes.key?(id)

          nodes[id] = Node.new(id, value, type)
        end

        def add_subgraph(id, name)
          return if subgraphs.key?(id)

          subgraphs[id] = Subgraph.new(id, name, [])
        end

        def add_node_to_subgraph(id, node_id)
          return if subgraphs[id]&.nodes&.include?(node_id)

          subgraphs[id].nodes << node_id
        end
      end
    end
  end
end
