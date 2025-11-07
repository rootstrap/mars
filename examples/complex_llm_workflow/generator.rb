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

sports_schema = SportsSchema.new

# Define weather tool
class Weather < RubyLLM::Tool
  description "Gets current weather for a location"

  params do
    string :latitude, description: "Latitude (e.g., 52.5200)"
    string :longitude, description: "Longitude (e.g., 13.4050)"
  end

  def execute(latitude:, longitude:)
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,wind_speed_10m"

    puts "Tool called with URL: #{url}"
    response = Net::HTTP.get_response(URI(url))
    data = JSON.parse(response.body)
    puts "Response: #{data}"
    data
  rescue => e
    { error: e.message }
  end
end

weather_tool = Weather.new

# Create the LLMs
llm1 = Mars::Agent.new(
  name: "LLM 1", options: { model: "gpt-4o" },
  instructions: "You are a helpful assistant that can answer questions. When asked about a country, only answer with its name."
)

llm2 = Mars::Agent.new(name: "LLM 2", options: { model: "gpt-4o" },
                       instructions: "You are a helpful assistant that can answer questions and help with tasks.
                       Return information about the typical food of the country.")

llm3 = Mars::Agent.new(name: "LLM 3", options: { model: "gpt-4o" }, schema: sports_schema,
                       instructions: "You are a helpful assistant that can answer questions and help with tasks.
                       Return information about the popular sports of the country.")

llm4 = Mars::Agent.new(name: "LLM 4", options: { model: "gpt-4o" }, tools: [weather_tool],
                       instructions: "You are a helpful assistant that can answer questions and help with tasks.
                       Return the current weather of the country's capital.")

parallel_workflow = Mars::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm2, llm3, llm4]
)

gate = Mars::Gate.new(
  name: "Gate",
  condition: ->(input) { input.split.length < 10 ? :success : :error },
  branches: {
    success: parallel_workflow
  }
)

sequential_workflow = Mars::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [llm1, gate]
)

# Generate and save the diagram
diagram = Mars::Rendering::Mermaid.new(sequential_workflow).render
File.write("examples/complex_llm_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_llm_workflow/diagram.md"

# Run the workflow
puts sequential_workflow.run("Which is the largest country in South America?")
