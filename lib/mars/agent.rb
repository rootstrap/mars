# frozen_string_literal: true

module Mars
  class Agent < Runnable
    def initialize(name:, tools: [], schema: nil, options:)
      @name = name
      @tools = Array(tools)
      @schema = schema
      @options = options
    end

    def run(input)
      chat.ask(input)
    end

    private

    attr_reader :name, :tools, :schema, :options

    def chat
      @chat ||= RubyLLM::Chat.new(**options).with_tools(tools).with_schema(schema)
    end
  end
end
