#!/usr/bin/env ruby
# frozen_string_literal: true

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

# Define RubyLLM agents
class CountryAgent < RubyLLM::Agent
  model "gpt-4o"
  instructions "You are a helpful assistant that can answer questions. " \
               "When asked about a country, only answer with its name."
end

class FoodAgent < RubyLLM::Agent
  model "gpt-4o"
  instructions "You are a helpful assistant. Return information about the typical food of the country."
end

class SportsAgent < RubyLLM::Agent
  model "gpt-4o"
  instructions "You are a helpful assistant. Return information about the popular sports of the country."
  schema SportsSchema
end

class WeatherAgent < RubyLLM::Agent
  model "gpt-4o"
  instructions "You are a helpful assistant. Return the current weather of the country's capital."
  tools Weather
end

# Define MARS steps wrapping RubyLLM agents
class CountryStep < MARS::AgentStep
  agent CountryAgent
end

class FoodStep < MARS::AgentStep
  agent FoodAgent
end

class SportsStep < MARS::AgentStep
  agent SportsAgent
end

class WeatherStep < MARS::AgentStep
  agent WeatherAgent
end

# Create the steps
llm1 = CountryStep.new(name: "Country")
llm2 = FoodStep.new(name: "Food")
llm3 = SportsStep.new(name: "Sports")
llm4 = WeatherStep.new(name: "Weather")

parallel_workflow = MARS::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm2, llm3, llm4]
)

error_workflow = MARS::Workflows::Sequential.new(
  "Error workflow",
  steps: []
)

gate = MARS::Gate.new(
  condition: ->(input) { input.split.length < 10 ? :success : :failure },
  branches: {
    failure: error_workflow
  }
)

sequential_workflow = MARS::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [llm1, gate, parallel_workflow]
)

# Generate and save the diagram
diagram = MARS::Rendering::Mermaid.new(sequential_workflow).render
File.write("examples/complex_llm_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_llm_workflow/diagram.md"
MARS::Rendering::Html.new(sequential_workflow).write("examples/complex_llm_workflow/diagram.html")
puts "Complex workflow beautiful mermaid diagram saved to: examples/complex_llm_workflow/diagram.html"

# Run the workflow
puts sequential_workflow.run("Which is the largest country in Europe?")
