#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

RubyLLM.configure do |config|
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)
end

# Create the LLMs
llm1 = Mars::Agent.new(
  name: "LLM 1", options: { model: "gpt-4o" },
  instructions: "You are a helpful assistant that can answer questions and help with tasks. Only answer with the result"
)

llm2 = Mars::Agent.new(name: "LLM 2", options: { model: "gpt-4o" },
                       instructions: "You are a helpful assistant that can answer questions and help with tasks.
                       Return information about the typical food of the country.")

llm3 = Mars::Agent.new(name: "LLM 3", options: { model: "gpt-4o" },
                       instructions: "You are a helpful assistant that can answer questions and help with tasks.
                       Return information about the popular sports of the country.")

parallel_workflow = Mars::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm2, llm3]
)

gate = Mars::Gate.new(
  name: "Gate",
  condition: ->(input) { input.split.length < 10 ? :success : :error },
  branches: {
    success: parallel_workflow
  }
)

sequential_workflow = Mars::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [llm1, gate]
)

puts sequential_workflow.run("Which is the last country to declare independence?")
