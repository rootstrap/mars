# frozen_string_literal: true

module Mars
  class Renderer
    def initialize(obj)
      @obj = obj
    end

    def to_mermaid(options = {})
      direction = options.fetch(:direction, "LR")

      <<~MERMAID
        ```mermaid
        flowchart #{direction}
        In(("In")) -->
        #{@obj.to_mermaid}
        ```
      MERMAID
    end
  end
end
