# frozen_string_literal: true

module MARS
  module Rendering
    class Html
      MERMAID_CDN = "https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"

      def initialize(obj)
        @mermaid = Mermaid.new(obj)
      end

      def render
        diagram = @mermaid.graph_mermaid.join("\n")
        direction = "LR"

        <<~HTML
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>MARS Workflow</title>
            <script src="#{MERMAID_CDN}"></script>
          </head>
          <body>
            <pre class="mermaid">
          flowchart #{direction}
          #{diagram}
            </pre>
            <script>mermaid.initialize({ startOnLoad: true });</script>
          </body>
          </html>
        HTML
      end
    end
  end
end
