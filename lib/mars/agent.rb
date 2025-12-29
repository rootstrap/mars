# frozen_string_literal: true

module Mars
  class Agent < Runnable
    def initialize(options: {}, **kwargs)
      super(**kwargs)

      @options = options
    end

    def run(input)
      processed_input = before_run(input)
      response = chat.ask(processed_input).content
      after_run(response)
    end

    private

    attr_reader :options

    def chat
      @chat ||= RubyLLM::Chat.new(**options)
                             .with_instructions(system_prompt)
                             .with_tools(*tools)
                             .with_schema(schema)
    end

    def before_run(input)
      input
    end

    def after_run(response)
      response
    end

    def system_prompt
      nil
    end

    def tools
      []
    end

    def schema
      nil
    end
  end
end
