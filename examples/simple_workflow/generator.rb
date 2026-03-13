#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

class ResolveCountryAgent < RubyLLM::Agent
  instructions "Answer with only the country name."
end

class ResolveCountry < MARS::AgentStep
  agent ResolveCountryAgent
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
    ResolveCountry.new,
    gate
  ]
)

diagram = MARS::Rendering::Mermaid.new(main_workflow).render
File.write("examples/simple_workflow/diagram.md", diagram)
puts "Simple workflow diagram saved to: examples/simple_workflow/diagram.md"
