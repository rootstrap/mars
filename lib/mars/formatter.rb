# frozen_string_literal: true

module MARS
  class Formatter
    def format_input(context)
      context.current_input
    end

    def format_output(output)
      Result.wrap(output)
    end
  end
end
