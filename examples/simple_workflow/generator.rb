#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

# Create the LLMs
llm1 = Mars::Agent.new(name: "LLM 1")

llm2 = Mars::Agent.new(name: "LLM 2")

llm3 = Mars::Agent.new(name: "LLM 3")

# Create the success workflow (LLM 2 -> LLM 3)
success_workflow = Mars::Workflows::Sequential.new(
  "Success workflow",
  steps: [llm2, llm3]
)

# Create the gate that decides between exit or continue
gate = Mars::Gate.new(
  name: "Gate",
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
diagram = main_workflow.to_mermaid_flowchart
File.write("examples/simple_workflow/diagram.md", diagram)
puts "Simple workflow diagram saved to: examples/simple_workflow/diagram.md"
