# frozen_string_literal: true

module Mars
  class Agent < Runnable
    attr_reader :name

    def initialize(name:, options: {}, tools: [], schema: nil, instructions: nil)
      @name = name
      @tools = Array(tools)
      @schema = schema
      @options = options
      @instructions = instructions
    end

    def run(input)
      chat.ask(input).content
    end

    private

    attr_reader :tools, :schema, :options, :instructions

    def chat
      @chat ||= RubyLLM::Chat.new(**options)
                             .with_instructions(instructions)
                             .with_tools(*tools)
                             .with_schema(schema)
    end
  end
end
