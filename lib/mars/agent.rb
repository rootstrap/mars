# frozen_string_literal: true

module Mars
  class Agent < Runnable
    attr_reader :name

    def initialize(name:, options: {}, tools: [], schema: nil, instructions: nil, **kwargs)
      super(**kwargs)

      @name = name
      @tools = Array(tools)
      @schema = schema
      @options = options
      @instructions = instructions
    end

    def run(input)
      processed_input = before_run(input)
      response = chat.ask(processed_input).content
      after_run(response)
    end

    private

    attr_reader :tools, :schema, :options, :instructions

    def chat
      @chat ||= RubyLLM::Chat.new(**options)
                             .with_instructions(instructions)
                             .with_tools(*tools)
                             .with_schema(schema)
    end

    def before_run(input)
      input
    end

    def after_run(response)
      response
    end
  end
end
