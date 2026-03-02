#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

# Define LLMs
class Agent1 < MARS::AgentStep
end

class Agent2 < MARS::AgentStep
end

class Agent3 < MARS::AgentStep
end

class Agent4 < MARS::AgentStep
end

class Agent5 < MARS::AgentStep
end

# Create the LLMs
llm1 = Agent1.new
llm2 = Agent2.new
llm3 = Agent3.new
llm4 = Agent4.new
llm5 = Agent5.new

# Create a parallel workflow (LLM 2 x LLM 3)
parallel_workflow = MARS::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm2, llm3]
)

# Create a sequential workflow (Parallel workflow -> LLM 4)
sequential_workflow = MARS::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [llm4, parallel_workflow]
)

# Create a parallel workflow (Sequential workflow x LLM 5)
parallel_workflow2 = MARS::Workflows::Parallel.new(
  "Parallel workflow 2",
  steps: [sequential_workflow, llm5]
)

# Create the gate that decides between exit or continue
gate = MARS::Gate.new(
  condition: ->(input) { input[:result] },
  branches: {
    warning: sequential_workflow,
    error: parallel_workflow
  }
)

# Create the main workflow: LLM 1 -> Gate
main_workflow = MARS::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [llm1, gate, parallel_workflow2]
)

# Generate and save the diagram
diagram = MARS::Rendering::Mermaid.new(main_workflow).render
File.write("examples/complex_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_workflow/diagram.md"
MARS::Rendering::Html.new(main_workflow).write("examples/complex_workflow/diagram.html")
puts "Complex workflow beautiful mermaid diagram saved to: examples/complex_workflow/diagram.html"
