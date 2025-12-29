#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

# Define the LLMs
class Agent1 < Mars::Agent
end

class Agent2 < Mars::Agent
end

class Agent3 < Mars::Agent
end

# Create the LLMs
llm1 = Agent1.new
llm2 = Agent2.new
llm3 = Agent3.new

# Create the success workflow (LLM 2 -> LLM 3)
success_workflow = Mars::Workflows::Sequential.new(
  "Success workflow",
  steps: [llm2, llm3]
)

# Create the gate that decides between exit or continue
gate = Mars::Gate.new(
  condition: ->(input) { input[:result] },
  branches: {
    success: success_workflow
  }
)

# Create the main workflow: LLM 1 -> Gate
main_workflow = Mars::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [llm1, gate]
)

# Generate and save the diagram
diagram = Mars::Rendering::Mermaid.new(main_workflow).render
File.write("examples/simple_workflow/diagram.md", diagram)
puts "Simple workflow diagram saved to: examples/simple_workflow/diagram.md"
