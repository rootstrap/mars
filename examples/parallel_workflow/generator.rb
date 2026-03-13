#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

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

parallel_workflow = MARS::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [
    ResearchFood.new,
    ResearchSports.new,
    ResearchWeather.new
  ]
)

diagram = MARS::Rendering::Mermaid.new(parallel_workflow).render
File.write("examples/parallel_workflow/diagram.md", diagram)
puts "Parallel workflow diagram saved to: examples/parallel_workflow/diagram.md"
