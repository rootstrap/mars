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

class Agent4 < MARS::AgentStep
end

# Create the LLMs
llm1 = Agent1.new
llm2 = Agent2.new
llm3 = Agent3.new
llm4 = Agent4.new

# Create the failure workflow (LLM 3)
failure_workflow = MARS::Workflows::Sequential.new(
  "Failure workflow",
  steps: [llm4]
)

# Create the gate that decides between exit or continue
gate = MARS::Gate.new(
  check: ->(input) { input[:result] },
  fallbacks: {
    failure: failure_workflow
  }
)

# Create the main workflow: LLM 1 -> Gate
main_workflow = MARS::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [llm1, gate, llm2, llm3]
)

# Generate and save the diagram
diagram = MARS::Rendering::Mermaid.new(main_workflow).render
File.write("examples/simple_workflow/diagram.md", diagram)
puts "Simple workflow diagram saved to: examples/simple_workflow/diagram.md"
