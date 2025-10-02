# frozen_string_literal: true

module Mars
  class Exit < Runnable
    include MermaidRenderable

    def initialize(name: "Exit")
      @name = name
    end

    def run(input)
      input
    end

    def to_mermaid
      "exit((#{name}))"
    end
  end
end
