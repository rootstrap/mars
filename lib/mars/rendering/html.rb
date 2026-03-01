# frozen_string_literal: true

module MARS
  module Rendering
    class Html
      BEAUTIFUL_MERMAID_URL = "https://esm.sh/beautiful-mermaid@1"

      attr_reader :obj

      def initialize(obj)
        @obj = obj
      end

      def render(options = {})
        mermaid = Mermaid.new(obj)
        diagram = mermaid.graph_mermaid.join("\n")
        direction = options.fetch(:direction, "LR")
        title = options.fetch(:title, obj.name)
        theme = options.fetch(:theme, {})

        build_html(title, direction, diagram, theme)
      end

      def write(path, options = {})
        File.write(path, render(options))
      end

      private

      def build_html(title, direction, diagram, theme)
        <<~HTML
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>#{escape(title)}</title>
            #{head_style}
          </head>
          <body>
            <h1>#{escape(title)}</h1>
            <div id="diagram"></div>
            #{render_script(direction, diagram, theme)}
          </body>
          </html>
        HTML
      end

      def head_style
        <<~STYLE.chomp
          <style>
              body { font-family: system-ui, sans-serif; margin: 2rem; background: #fafafa; }
              h1 { color: #333; }
              #diagram { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
            </style>
        STYLE
      end

      def render_script(direction, diagram, theme)
        theme_opts = theme_options(theme)

        <<~SCRIPT.chomp
          <script type="module">
              import { renderMermaidSVG } from "#{BEAUTIFUL_MERMAID_URL}";
              const diagram = `flowchart #{direction}\n#{escape_js(diagram)}`;
              const svg = renderMermaidSVG(diagram#{theme_opts});
              document.getElementById("diagram").innerHTML = svg;
            </script>
        SCRIPT
      end

      def theme_options(theme)
        return "" if theme.empty?

        pairs = theme.map { |k, v| "#{k}: '#{escape_js(v.to_s)}'" }
        ", { #{pairs.join(", ")} }"
      end

      def escape(text)
        text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
      end

      def escape_js(text)
        text.to_s.gsub("\\", "\\\\\\\\").gsub("`", "\\`").gsub("$", "\\$")
      end
    end
  end
end
