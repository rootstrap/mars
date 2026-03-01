#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

# Define the LLMs
class Agent1 < MARS::AgentStep
end

class Agent2 < MARS::AgentStep
end

class Agent3 < MARS::AgentStep
end

# Create the LLMs
llm1 = Agent1.new
llm2 = Agent2.new
llm3 = Agent3.new

# Create the success workflow (LLM 2 -> LLM 3)
success_workflow = MARS::Workflows::Sequential.new(
  "Success workflow",
  steps: [llm2, llm3]
)

# Create the gate that decides between exit or continue
gate = MARS::Gate.new(
  condition: ->(input) { input[:result] },
  branches: {
    success: success_workflow
  }
)

# Create the main workflow: LLM 1 -> Gate
main_workflow = MARS::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [llm1, gate]
)

# Generate and save the diagram
diagram = MARS::Rendering::Mermaid.new(main_workflow).render
File.write("examples/simple_workflow/diagram.md", diagram)
puts "Simple workflow diagram saved to: examples/simple_workflow/diagram.md"
