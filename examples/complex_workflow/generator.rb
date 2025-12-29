#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

# Define LLMs
class Agent1 < Mars::Agent
end

class Agent2 < Mars::Agent
end

class Agent3 < Mars::Agent
end

class Agent4 < Mars::Agent
end

class Agent5 < Mars::Agent
end

# Create the LLMs
llm1 = Agent1.new
llm2 = Agent2.new
llm3 = Agent3.new
llm4 = Agent4.new
llm5 = Agent5.new

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
