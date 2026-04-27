#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

class Step1Formatter < MARS::Formatter
  def format_output(context)
    context + ['formatted']
  end
end

class Step1 < MARS::Runnable
  after_run do |context, result|
    puts "after run from Step1 #{result}"
  end
  formatter Step1Formatter

  def run(context)
    context.current_input + ['step1']
  end
end

class Step2 < MARS::Runnable
  after_run do |context, result|
    puts "after run from Step2 #{result}"
  end

  def run(context)
    context.current_input + ['step2']
  end
end

class Step3 < MARS::Runnable
  after_run do |context, result|
   puts "after run from Step3 #{result}"
  end

  def run(context)
    context.current_input + ['step3']
  end
end

class Step4 < MARS::Runnable
  after_run do |context, result|
    puts "after run from Step4 #{result}"
  end

  def run(context)
    context.current_input + ['step4']
  end
end

class Step5 < MARS::Runnable
  after_run do |context, result|
    puts "after run from Step5 #{result}"
  end

  def run(context)
    context.current_input + ['step5']
  end
end

# Create the Steps
step1 = Step1.new
step2 = Step2.new
step3 = Step3.new
step4 = Step4.new
step5 = Step5.new

# Create a parallel workflow (STEP 2 x STEP 3)
parallel_workflow = MARS::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [step2, step3]
)

# Create a sequential workflow (Parallel workflow -> LLM 4)
sequential_workflow = MARS::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [step4, parallel_workflow]
)

# Create a parallel workflow (Sequential workflow x LLM 5)
parallel_workflow2 = MARS::Workflows::Parallel.new(
  "Parallel workflow 2",
  steps: [sequential_workflow, step5]
)

# Create the gate that decides between exit or continue
gate = MARS::Gate.new(
  check: ->(input) { nil if input == ["start", "step1", "formatted"] },
  fallbacks: {
    warning: sequential_workflow,
    error: parallel_workflow
  }
)

# Create the main workflow: LLM 1 -> Gate
main_workflow = MARS::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [step1, gate, parallel_workflow2]
)

main_workflow.run(["start"])

# Generate and save the diagram
diagram = MARS::Rendering::Mermaid.new(main_workflow).render
File.write("examples/complex_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_workflow/diagram.md"
