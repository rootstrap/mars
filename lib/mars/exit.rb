# frozen_string_literal: true

module Mars
  class Exit < Runnable
    attr_reader :name

    def initialize(name: "Exit")
      @name = name
    end

    def run(input)
      input
    end
  end
end
