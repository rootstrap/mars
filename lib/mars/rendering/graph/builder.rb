# frozen_string_literal: true

require "set"

module MARS
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
          return if adjacency[from].include?([to, value])
          return if reachable?(to, from)

          adjacency[from] << [to, value]
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
          return if node_in_any_subgraph?(node_id)

          subgraphs[id].nodes << node_id
        end

        private

        def node_in_any_subgraph?(node_id)
          subgraphs.values.any? { |sg| sg.nodes.include?(node_id) }
        end

        def reachable?(from, target)
          visited = Set.new
          queue = [from]

          while queue.any?
            current = queue.shift
            next if visited.include?(current)

            visited << current
            return true if current == target

            adjacency[current]&.each { |(to, _)| queue << to }
          end

          false
        end
      end
    end
  end
end
