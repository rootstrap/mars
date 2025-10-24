# frozen_string_literal: true

module Mars
  module Rendering
    module Graph
      class Node
        STEP = :step
        OUTPUT = :output
        INPUT = :input
        GATE = :gate

        attr_reader :id, :name, :type

        def initialize(id, name, type)
          @id = id
          @name = name
          @type = type
        end
      end
    end
  end
end
