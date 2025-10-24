#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

# Create the LLMs
llm1 = Mars::Agent.new(name: "LLM 1")

llm2 = Mars::Agent.new(name: "LLM 2")

llm3 = Mars::Agent.new(name: "LLM 3")

llm4 = Mars::Agent.new(name: "LLM 4")

llm5 = Mars::Agent.new(name: "LLM 5")

# Create a parallel workflow (LLM 2 x LLM 3)
parallel_workflow = Mars::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm2, llm3]
)

# Create a sequential workflow (Parallel workflow -> LLM 4)
sequential_workflow = Mars::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [llm4, parallel_workflow]
)

# Create a parallel workflow (Sequential workflow x LLM 5)
parallel_workflow2 = Mars::Workflows::Parallel.new(
  "Parallel workflow 2",
  steps: [sequential_workflow, llm5]
)

# Create the gate that decides between exit or continue
gate = Mars::Gate.new(
  name: "Gate",
  condition: ->(input) { input[:result] },
  branches: {
    success: parallel_workflow2,
    warning: sequential_workflow,
    error: parallel_workflow
  }
)

# Create the main workflow: LLM 1 -> Gate
main_workflow = Mars::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [llm1, gate]
)

# Generate and save the diagram
diagram = Mars::Rendering::Mermaid.new(main_workflow).render
File.write("examples/complex_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_workflow/diagram.md"
