# frozen_string_literal: true

module Mars
  module MermaidRenderable
    attr_reader :name

    def to_mermaid
      raise NotImplementedError
    end

    def to_mermaid_flowchart(direction: "LR")
      <<~MERMAID
        ```mermaid
        flowchart #{direction}
        In(("In")) -->
        #{to_mermaid}
        ```
      MERMAID
    end

    def can_end_workflow?
      false
    end

    def sanitized_name
      name.to_s.gsub(/[^a-zA-Z0-9_]/, "_")
    end
  end
end
