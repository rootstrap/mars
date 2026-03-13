#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "../../lib/mars"

RubyLLM.configure do |config|
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)
end

# Define schema for sports
class SportsSchema < RubyLLM::Schema
  array :sports do
    object do
      string :name
      array :top_3_players do
        string :name
      end
    end
  end
end

# Define weather tool
class Weather < RubyLLM::Tool
  description "Gets current weather for a location"

  params do
    string :latitude, description: "Latitude (e.g., 52.5200)"
    string :longitude, description: "Longitude (e.g., 13.4050)"
  end

  def execute(latitude:, longitude:)
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,wind_speed_10m"
    response = Net::HTTP.get_response(URI(url))
    JSON.parse(response.body)
  rescue StandardError => e
    { error: e.message }
  end
end

class ResolveCountryAgent < RubyLLM::Agent
  instructions "Answer with only the country name."
end

class TypicalFoodAgent < RubyLLM::Agent
  instructions "Return information about the typical food of the country."
end

class PopularSportsAgent < RubyLLM::Agent
  instructions "Return information about the popular sports of the country."
  schema SportsSchema.new
end

class CapitalWeatherAgent < RubyLLM::Agent
  instructions "Return the current weather of the country's capital."
  tools Weather.new
end

class ResolveCountry < MARS::AgentStep
  agent ResolveCountryAgent
end

class TypicalFood < MARS::AgentStep
  agent TypicalFoodAgent
end

class PopularSports < MARS::AgentStep
  agent PopularSportsAgent
end

class CapitalWeather < MARS::AgentStep
  agent CapitalWeatherAgent
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

class BuildReport < MARS::Aggregator
  def run(results, ctx: {})
    result(
      value: {
        country: ctx[:resolve_country].value,
        food: results[0].value,
        sports: results[1].value,
        weather: results[2].value
      }
    )
  end
end

parallel_workflow = MARS::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [
    TypicalFood.new,
    PopularSports.new,
    CapitalWeather.new
  ],
  aggregator: BuildReport.new
)

gate = MARS::Gate.new(
  "country_guard",
  check: ->(input, _ctx) { :failure unless input.value.split.length < 10 },
  branches: {
    failure: TooBroad.new
  }
)

sequential_workflow = MARS::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [
    ResolveCountry.new,
    gate,
    parallel_workflow
  ]
)

diagram = MARS::Rendering::Mermaid.new(sequential_workflow).render
File.write("examples/complex_llm_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_llm_workflow/diagram.md"

result = sequential_workflow.run("Which is the largest country in Europe?")
pp result.value
