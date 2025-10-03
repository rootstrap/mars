# frozen_string_literal: true

module Mars
  class Agent < Runnable
    attr_reader :name

    def initialize(name:, options: {}, tools: [], schema: nil)
      @name = name
      @tools = Array(tools)
      @schema = schema
      @options = options
    end

    def run(input)
      chat.ask(input)
    end

    private

    attr_reader :tools, :schema, :options

    def chat
      @chat ||= RubyLLM::Chat.new(**options).with_tools(tools).with_schema(schema)
    end
  end
end
