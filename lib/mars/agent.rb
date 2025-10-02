# frozen_string_literal: true

module Mars
  class Agent < Runnable
    include MermaidRenderable

    def initialize(name:, options: {}, tools: [], schema: nil)
      @name = name
      @tools = Array(tools)
      @schema = schema
      @options = options
    end

    def run(input)
      chat.ask(input)
    end

    def to_mermaid
      "#{sanitized_name}[\"#{name}\"]"
    end

    def can_end_workflow?
      true
    end

    private

    attr_reader :name, :tools, :schema, :options

    def chat
      @chat ||= RubyLLM::Chat.new(**options).with_tools(tools).with_schema(schema)
    end
  end
end
