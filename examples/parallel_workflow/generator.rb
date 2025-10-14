#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

# Create the LLMs
llm1 = Mars::Agent.new(name: "LLM 1")

llm2 = Mars::Agent.new(name: "LLM 2")

llm3 = Mars::Agent.new(name: "LLM 3")

# Create the parallel workflow (LLM 1, LLM 2, LLM 3)
parallel_workflow = Mars::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm1, llm2, llm3]
)

# Generate and save the diagram
diagram = Mars::Rendering::Mermaid.render(parallel_workflow)
File.write("examples/parallel_workflow/diagram.md", diagram)
puts "Parallel workflow diagram saved to: examples/parallel_workflow/diagram.md"
