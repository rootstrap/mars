#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

class NormalizeQuestion < MARS::Step
  def run(input, ctx: {})
    result(value: input.value.strip)
  end
end

class ResearchFood < MARS::Step
  def run(input, ctx: {})
    result(value: "Typical food of #{input.value}")
  end
end

class ResearchSports < MARS::Step
  def run(input, ctx: {})
    result(value: "Popular sports of #{input.value}")
  end
end

class ResearchWeather < MARS::Step
  def run(input, ctx: {})
    result(value: "Current weather in the capital of #{input.value}")
  end
end

class TooBroad < MARS::Step
  def run(input, ctx: {})
    result(
      value: {
        error: "Please ask about one country",
        resolved_value: input.value
      }
    )
  end
end

parallel_workflow = MARS::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [
    ResearchFood.new,
    ResearchSports.new
  ]
)

sequential_workflow = MARS::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [
    parallel_workflow,
    ResearchWeather.new
  ]
)

parallel_workflow2 = MARS::Workflows::Parallel.new(
  "Parallel workflow 2",
  steps: [
    sequential_workflow,
    NormalizeQuestion.new
  ]
)

gate = MARS::Gate.new(
  "country_guard",
  check: ->(input, _ctx) { :too_broad if input.value.split.size > 5 },
  branches: {
    too_broad: TooBroad.new
  }
)

main_workflow = MARS::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [
    NormalizeQuestion.new,
    gate,
    parallel_workflow2
  ]
)

diagram = MARS::Rendering::Mermaid.new(main_workflow).render
File.write("examples/complex_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_workflow/diagram.md"
