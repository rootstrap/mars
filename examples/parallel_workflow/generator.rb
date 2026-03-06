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

aggregator = MARS::Aggregator.new("Aggregator", operation: lambda(&:sum))

# Create the parallel workflow (LLM 1, LLM 2, LLM 3)
parallel_workflow = MARS::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm1, llm2, llm3],
  aggregator: aggregator
)

# Generate and save the diagram
diagram = MARS::Rendering::Mermaid.new(parallel_workflow).render
File.write("examples/parallel_workflow/diagram.md", diagram)
puts "Parallel workflow diagram saved to: examples/parallel_workflow/diagram.md"
